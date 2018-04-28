{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
module Boris.Http.Api.Build (
    byId
  , list
  , queued
  , submit
  , heartbeat
  , acknowledge
  , cancel
  , byCommit
  , byProject
  , logOf
  , avow
  , complete
  , BuildError (..)
  , renderBuildError
  ) where


import           Control.Monad.IO.Class (MonadIO (..))

import qualified Data.Text as Text
import qualified Data.Time as Time

import           Boris.Core.Data.Build
import           Boris.Core.Data.Log
import           Boris.Core.Data.Project
import           Boris.Core.Data.Tenant
import qualified Boris.Http.Api.Project as Project
import           Boris.Http.Data
import qualified Boris.Http.Db.BuildId as BuildIdDb
import qualified Boris.Http.Db.Query as Query

import           P

import           System.IO (IO)

import           Traction.Control (DbPool, DbError)
import qualified Traction.Control as Traction

import           X.Control.Monad.Trans.Either (EitherT)

data BuildError =
    BuildDbError Traction.DbError

renderBuildError :: BuildError -> Text
renderBuildError err =
  case err of
    BuildDbError e ->
      mconcat ["Build error via db: ", Traction.renderDbError e]

byId :: DbPool -> BuildId -> EitherT DbError IO (Maybe BuildData)
byId pool build =
  Traction.runDb pool $ do
    result <- Query.fetch build
    for result $ \r ->
      case buildDataResult r of
        Nothing ->
          case buildDataHeartbeatTime r of
            Nothing -> do
              case buildDataCancelled r of
                Nothing ->
                  pure r
                Just BuildNotCancelled ->
                  pure r
                Just BuildCancelled ->
                  pure $ r { buildDataResult = Just . fromMaybe BuildKo . buildDataResult $ r }
            Just h -> do
              now <- liftIO Time.getCurrentTime
              if Time.diffUTCTime now h > 120
                then do
                  Query.cancel build
                  pure $ r { buildDataResult = Just . fromMaybe BuildKo . buildDataResult $ r }
                else
                  pure r
        Just _ ->
          pure r

list :: DbPool -> Project -> Build -> EitherT DbError IO BuildTree
list pool project build = Traction.runDb pool $ do
  refs <- Query.getBuildRefs project build
  BuildTree project build <$> (for refs $ \ref ->
    BuildTreeRef ref <$> Query.getBuildIds project build ref)

queued :: DbPool -> Project -> Build -> EitherT DbError IO [BuildId]
queued pool project build =
  Traction.runDb pool $
  Query.getQueued project build

submit :: DbPool -> Tenant -> AuthenticatedBy -> Project -> Build -> Maybe Ref -> EitherT BuildError IO (Maybe BuildId)
submit pool tenant authenticated project build ref = do
  repository' <- firstT BuildDbError $
    Project.pick pool tenant authenticated project
  case repository' of
    Nothing ->
      pure Nothing
    Just _repository -> do
      let
        -- FIX this needs to be stored with register
        _normalised = with ref $ \rr ->
          if Text.isPrefixOf "refs/" . renderRef $ rr then rr else Ref . ((<>) "refs/heads/") . renderRef $ rr
      firstT BuildDbError . Traction.runDb pool $ do
        i <- BuildIdDb.tick
        Query.register project build i
        pure $ Just i

heartbeat :: DbPool -> BuildId -> EitherT DbError IO BuildCancelled
heartbeat pool  buildId =
  Traction.runDb pool $
    Query.heartbeat buildId

acknowledge :: DbPool -> BuildId -> EitherT DbError IO Acknowledge
acknowledge pool buildId =
  Traction.runDb pool $
    Query.acknowledge buildId

cancel :: DbPool -> BuildId -> EitherT DbError IO (Maybe ())
cancel pool i =
  Traction.runDb pool $ do
    d <- Query.fetch i
    for d $ \_ ->
        Query.cancel i

byCommit :: DbPool -> Project -> Commit -> EitherT DbError IO [BuildId]
byCommit pool project commit =
  Traction.runDb pool $
    Query.getProjectCommitBuildIds project commit

byProject :: DbPool -> ProjectId -> EitherT DbError IO [Build]
byProject pool project =
  Traction.runDb pool $
    Query.getProjects project

logOf :: DbPool -> BuildId -> EitherT DbError IO (Maybe LogData)
logOf pool i =
  Traction.runDb pool $ do
    d <- Query.fetch i
    for d $ \_ ->
      Query.fetchLogData i

avow :: DbPool -> BuildId -> Ref -> Commit -> EitherT DbError IO ()
avow pool i ref commit =
  Traction.runDb pool $
    Query.index i ref commit

complete :: DbPool -> BuildId -> BuildResult -> EitherT DbError IO ()
complete pool i result =
  void . Traction.runDb pool $
    Query.complete i result

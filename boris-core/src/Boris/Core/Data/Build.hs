{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
module Boris.Core.Data.Build (
    BuildName (..)
  , BuildId (..)
  , Build (..)
  , Commit (..)
  , Ref (..)
  , Pattern (..)
  , sortBuildIds
  , newBuildName
  , renderBuildId

  , Acknowledge (..)

  , BuildResult (..)
  , BuildCancelled (..)
  , BuildData (..)
  , Result (..)
  , BuildTree (..)
  , BuildTreeRef (..)

  , renderBuildResult
  , parseBuildResult

  ) where

import           Boris.Core.Data.Keyed
import           Boris.Core.Data.Project

import qualified Data.List as List
import qualified Data.Text as Text
import           Data.Time (UTCTime)

import           Boris.Prelude


newtype BuildName =
  BuildName {
      renderBuildName :: Text
    } deriving (Eq, Ord, Show)

newtype BuildId =
  BuildId {
      getBuildId :: Int64
    } deriving (Eq, Ord, Show)

data Build =
  Build {
      buildProject :: Keyed ProjectId Project
    , buildName :: BuildName
    , buildRef :: Maybe Ref
    , buildCommit :: Maybe Commit
    , buildResult :: Maybe BuildResult
    , buildCancelled :: Maybe BuildCancelled
    , buildQueueTime :: Maybe UTCTime
    , buildStartTime :: Maybe UTCTime
    , buildEndTime :: Maybe UTCTime
    , buildHeartbeatTime :: Maybe UTCTime
    } deriving (Eq, Ord, Show)

renderBuildId :: BuildId -> Text
renderBuildId =
  Text.pack . show . getBuildId

newtype Ref =
  Ref {
      renderRef :: Text
    } deriving (Eq, Show, Ord)

newtype Pattern =
  Pattern {
      renderPattern :: Text
    } deriving (Eq, Show, Ord)

newtype Commit =
  Commit {
      renderCommit :: Text
    } deriving (Eq, Show, Ord)

sortBuildIds :: [BuildId] -> [BuildId]
sortBuildIds =
  List.reverse . List.sort

newBuildName :: Text -> Maybe BuildName
newBuildName b =
  emptyOrValue (Text.isInfixOf "/" b) $
    BuildName b

data Acknowledge =
    Accept
  | AlreadyRunning
    deriving (Eq, Ord, Show, Enum, Bounded)


data BuildResult =
    BuildOk
  | BuildKo
    deriving (Eq, Show, Ord, Enum, Bounded)

renderBuildResult :: BuildResult -> Text
renderBuildResult r =
  case r of
    BuildOk ->
      "ok"
    BuildKo ->
      "ko"

parseBuildResult :: Text -> Maybe BuildResult
parseBuildResult r =
  case r of
    "ok" ->
      Just BuildOk
    "ko" ->
      Just BuildKo
    _ ->
      Nothing

data BuildCancelled =
    BuildCancelled
  | BuildNotCancelled
    deriving (Eq, Ord, Show, Enum, Bounded)

data BuildData =
  BuildData {
      buildDataId :: BuildId
    , buildDataProject :: ProjectName
    , buildDataBuild :: BuildName
    , buildDataRef :: Maybe Ref
    , buildDataCommit :: Maybe Commit
    , buildDataQueueTime :: Maybe UTCTime
    , buildDataStartTime :: Maybe UTCTime
    , buildDataEndTime :: Maybe UTCTime
    , buildDataHeartbeatTime :: Maybe UTCTime
    , buildDataResult :: Maybe BuildResult
    , buildDataCancelled :: Maybe BuildCancelled
    } deriving (Eq, Ord, Show)

data Result =
  Result {
      resultBuildId :: !BuildId
    , resultProject :: !ProjectName
    , resultBuild :: !BuildName
    , resultRef :: !(Maybe Ref)
    , resultBuildResult :: !BuildResult
    } deriving (Eq, Show, Ord)


data BuildTree =
  BuildTree {
      buildTreeProject :: ProjectName
    , buildTreeBuild :: BuildName
    , buildTreeRefs :: [BuildTreeRef]
    } deriving (Eq, Ord, Show)

data BuildTreeRef =
  BuildTreeRef {
      buildTreeRef :: Ref
    , buildTreeIds :: [BuildId]
    } deriving (Eq, Ord, Show)

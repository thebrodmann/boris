{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
module Boris.Core.Serial.Toml (
    BorisConfigError (..)
  , parseConfig
  , renderBorisConfigError
  ) where

import           Boris.Core.Data

import           Control.Lens ((^?))

import           Data.Text (Text)
import qualified Data.Text as T
import qualified Data.HashMap.Strict as M

import           Text.Parsec.Error (ParseError)
import           Text.Toml (parseTomlDoc)
import           Text.Toml.Types (Table, TValue)

import           P

import           X.Text.Toml (_NTable, _NTValue, _VArray, _VString, _VInteger, key)

{--
# example config file

[boris]
  version = 1

[build.dist]
  refs = "refs/heads/master"

[build.branches]
  refs = "refs/heads/topic/*"

[build.hack]
  refs = "refs/heads/topic/hack"
  command = [["./mafia", "test"]]

[build.success]
  refs = "refs/heads/topic/hack"
  success = [["hipchat", "yo"]]

[build.validate]
  refs = "refs/heads/topic/hack"
  pre = [["validate-respect"], ["rebased"]]

--}


data BorisConfigError =
    ConfigTomlParseError ParseError
  | ConfigMissingVersionError
  | ConfigUnknownVersionError Int64
  | ConfigNoReference Build
  | ConfigInvalidCommand Build
  | ConfigBuildsTypeError
    deriving (Eq, Show)

parseConfig :: Text -> Either BorisConfigError [Specification]
parseConfig t =
  first ConfigTomlParseError (parseTomlDoc "boris.toml" t) >>= parseTomlConfig

parseTomlConfig :: Table -> Either BorisConfigError [Specification]
parseTomlConfig t =
  case t ^? key "boris" . _NTable . key "version" . _NTValue . _VInteger of
    Nothing ->
      Left ConfigMissingVersionError
    Just 1 ->
      parseTomlConfigV1 t
    Just n ->
      Left $ ConfigUnknownVersionError n

parseTomlConfigV1 :: Table -> Either BorisConfigError [Specification]
parseTomlConfigV1 t =
  parseBuilds t >>= \builds ->
    forM (M.keys builds) $ \k ->
      let
        build = Build k
      in
        Specification build
          <$> parseGit builds build
          <*> parseCommands builds build "pre"
          <*> parseCommands' builds build "command" [Command "master" ["build", k]]
          <*> parseCommands builds build "post"
          <*> parseCommands builds build "success"
          <*> parseCommands builds build "failure"

parseBuilds :: Table -> Either BorisConfigError Table
parseBuilds doc =
  case doc ^? key "build" of
    Nothing ->
      pure M.empty
    Just tt ->
      maybeToRight ConfigBuildsTypeError $
        tt ^? _NTable

parseGit :: Table -> Build -> Either BorisConfigError Query
parseGit builds build =
  fmap Query . maybeToRight (ConfigNoReference build) $
    builds ^? key (renderBuild build) . _NTable . key "git" . _NTValue . _VString

parseCommands :: Table -> Build -> Text -> Either BorisConfigError [Command]
parseCommands builds build t =
  parseCommands' builds build t []

parseCommands' :: Table -> Build -> Text -> [Command] -> Either BorisConfigError [Command]
parseCommands' builds build t dfault =
  case builds ^? key (renderBuild build) . _NTable . key t . _NTValue . _VArray of
    Nothing ->
      Right dfault
    Just [] ->
      Right []
    Just xs ->
      forM xs $ parseCommand build

parseCommand :: Build -> TValue -> Either BorisConfigError Command
parseCommand build table =
  case table ^? _VArray of
    Nothing ->
      Left $ ConfigInvalidCommand build
    Just [] ->
      Left $ ConfigInvalidCommand build
    Just xs ->
      case forM xs (^? _VString) of
        Nothing ->
          Left $ ConfigInvalidCommand build
        Just [] ->
          Left $ ConfigInvalidCommand build
        Just (cmd:args) ->
          Right $ Command cmd args

renderBorisConfigError :: BorisConfigError -> Text
renderBorisConfigError err =
  case err of
    ConfigTomlParseError p ->
      mconcat ["Boris configuration could not be parsed, toml parse error: ", T.pack . show $ p]
    ConfigMissingVersionError ->
      "Boris configuration does not contain a version field."
    ConfigUnknownVersionError n ->
      mconcat ["Boris configuration contains an unkown version: ", T.pack . show $ n]
    ConfigNoReference b ->
      mconcat ["Boris configuration does not contain a mandatory 'refs' for build: ", renderBuild b]
    ConfigInvalidCommand b ->
      mconcat ["Boris configuration contains an invalid 'command' for build: ", renderBuild b]
    ConfigBuildsTypeError ->
      mconcat ["Boris configuration should contain a top level table 'build'."]

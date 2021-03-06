{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
module Test.Boris.Core.Gen where

import           Boris.Core.Data.Agent
import           Boris.Core.Data.Build
import           Boris.Core.Data.Configuration
import           Boris.Core.Data.Log
import           Boris.Core.Data.Project
import           Boris.Prelude

import           Data.Text (Text)
import qualified Data.Text as Text
import           Data.Time (Day (..), DiffTime, UTCTime (..))

import           Hedgehog
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range


genRef :: Gen Ref
genRef =
  Ref <$> Gen.element [
      "master"
    , "topic/fred"
    , "topic/red"
    , "topic/green"
    , "topic/blue"
    , "topic/orange"
    , "topic/yellow"
    , "topic/indigo"
    , "topic/violet"
    ]

genCommit :: Gen Commit
genCommit =
  fmap (Commit . Text.pack . show) $
    Gen.int (Range.constant 0 99999)

genBuildId :: Gen BuildId
genBuildId =
  BuildId <$>
    Gen.int64 (Range.constant 0 99999)

genBuildName :: Gen BuildName
genBuildName =
  BuildName <$> Gen.element [
      "master"
    , "branches"
    ]

genBuildNamePattern :: Gen BuildNamePattern
genBuildNamePattern = do
  b <- genBuildName
  p <- either (const Gen.discard) (pure) $
    parseBuildNamePattern $ renderBuildName b
  pure $ p

genProjectName :: Gen ProjectName
genProjectName =
  ProjectName <$> Gen.element software

software :: [Text]
software = [
    "grep"
  , "sed"
  , "cut"
  , "comm"
  , "uniq"
  , "awk"
  , "nl"
  , "vi"
  , "diff"
  ]

planets :: [Text]
planets = [
    "mecury"
  , "venus"
  , "earth"
  , "mars"
  , "april"
  , "may"
  , "june"
  , "july"
  , "august"
  , "september"
  , "october"
  , "november"
  , "december"
  ]


genQueueSize :: Gen QueueSize
genQueueSize =
  fmap QueueSize $
    Gen.int (Range.constant 0 99999)

genPattern :: Gen Pattern
genPattern  =
  Pattern <$> Gen.element planets

genBuildTree :: Gen BuildTree
genBuildTree =
  BuildTree
    <$> genProjectName
    <*> genBuildName
    <*> Gen.list (Range.linear 1 100) genBuildTreeRef

genBuildTreeRef :: Gen BuildTreeRef
genBuildTreeRef =
  BuildTreeRef
    <$> genRef
    <*> fmap sortBuildIds (Gen.list (Range.linear 1 100) genBuildId)

genBuildData :: Gen BuildData
genBuildData =
  BuildData
    <$> genBuildId
    <*> genProjectName
    <*> genBuildName
    <*> Gen.maybe genRef
    <*> Gen.maybe genCommit
    <*> Gen.maybe genUTCTime
    <*> Gen.maybe genUTCTime
    <*> Gen.maybe genUTCTime
    <*> Gen.maybe genUTCTime
    <*> Gen.maybe genBuildResult
    <*> Gen.maybe genBuildCancelled

genResult :: Gen Result
genResult =
  Result
    <$> genBuildId
    <*> genProjectName
    <*> genBuildName
    <*> Gen.maybe genRef
    <*> genBuildResult

genBuildResult :: Gen BuildResult
genBuildResult =
  Gen.enumBounded

genBuildPattern :: Gen BuildPattern
genBuildPattern =
  BuildPattern
    <$> genBuildNamePattern
    <*> genPattern

genBuildCancelled :: Gen BuildCancelled
genBuildCancelled =
  Gen.enumBounded

genAcknowledge :: Gen Acknowledge
genAcknowledge =
  Gen.enumBounded

genUTCTime :: Gen UTCTime
genUTCTime =
  UTCTime
    <$> genDay
    <*> genDiffTime

genDay :: Gen Day
genDay =
  Gen.enum (ModifiedJulianDay 50000) (ModifiedJulianDay 60000)

genDiffTime :: Gen DiffTime
genDiffTime =
  fromRational . toRational <$> Gen.double (Range.linearFrac 0 86400)

data BuildWithPattern =
  BuildWithPattern BuildName BuildNamePattern
  deriving (Eq, Show)


genBuildNamePatternWith :: BuildName -> Gen BuildNamePattern
genBuildNamePatternWith b' = do
  let
    b = renderBuildName b'
  i <- Gen.int (Range.linear 0 (Text.length b))
  Gen.just . fmap (rightToMaybe . parseBuildNamePattern) . Gen.element $ [
      b
    , "*" <> Text.drop i b
    , Text.take i b <> "*"
    ]
    <> valueOrEmpty (i > 0) (Text.take (i - 1) b <> "?" <> Text.drop i b)


genBuildWithPattern :: Gen BuildWithPattern
genBuildWithPattern = do
  b <- genBuildName
  BuildWithPattern b <$> genBuildNamePatternWith b

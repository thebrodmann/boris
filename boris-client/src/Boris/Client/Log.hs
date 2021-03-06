{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
module Boris.Client.Log (
    fetch
  , push
  ) where

import qualified Boris.Client.Response as Response
import           Boris.Client.Request (Request (..))
import qualified Boris.Client.Request as Request
import qualified Boris.Client.Serial.Decode as Decode
import           Boris.Core.Data.Build
import           Boris.Core.Data.Log
import           Boris.Prelude
import           Boris.Representation.ApiV1

import qualified Network.HTTP.Types as HTTP


fetch :: BuildId -> Request [Log]
fetch i =
  Request HTTP.GET (mconcat ["log", renderBuildId i])
    (Response.json 200 $ Decode.wrapper getLogs)
    Request.none


push :: RunId -> [Log] -> Request ()
push i =
  Request HTTP.POST (mconcat ["log", renderRunId i])
    (Response.none 200)
    (Request.auto $ )

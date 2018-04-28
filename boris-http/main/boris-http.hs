{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
import qualified Boris.Http.Boot as Boot
import qualified Boris.Http.Route as Route
import qualified Boris.Http.Db.Schema as Schema
import qualified Boris.Http.Db.Settings as SettingsDb

import qualified Nest

import           P

import qualified System.IO as IO
import           System.IO (IO)

import qualified Traction.Control as Traction

import qualified Web.Spock.Core as Spock

import           X.Control.Monad.Trans.Either.Exit (orDie)


import Network.Wai.Handler.Warp (runSettings, defaultSettings, setPort, setOnException, defaultOnException)

main :: IO ()
main = do
  Boot.Boot mode authentication pool defaults <-
    Nest.force $ Boot.boot

  orDie Traction.renderDbError $
    Schema.initialise pool

  tenant <- orDie Traction.renderDbError $
    Traction.runDb pool SettingsDb.getTenant

  port <- Nest.force $ Nest.numeric "PORT" `Nest.withDefault` 10080

  routes <- case (tenant, defaults) of
    (Just _, _) ->
      pure $ Route.application pool authentication mode
    (Nothing, Just t) -> do
      orDie Traction.renderDbError $
        Traction.runDb pool $ SettingsDb.setTenant t
      pure $ Route.application pool authentication mode
    (Nothing, Nothing) -> do
      pure $ Route.configure pool authentication mode

  app <- Spock.spockAsApp $ Spock.spockConfigT Spock.defaultSpockConfig id routes

  let
    s = setPort port $
      setOnException (\req ex -> do
        IO.print ex
        defaultOnException req ex) $
          defaultSettings
  runSettings s app

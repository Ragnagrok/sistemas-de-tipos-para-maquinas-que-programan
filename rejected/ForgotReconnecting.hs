{-# OPTIONS_GHC -Werror=incomplete-patterns #-}
-- A new state is added tomorrow, and a function that handles connections
-- forgets it. The compiler points at it.
-- expects: Pattern match(es) are non-exhaustive
module ForgotReconnecting where

import Net

data Connection
  = Disconnected
  | Connecting   RetryCount
  | Connected    Socket
  | Failed       Error
  | Reconnecting RetryCount

describe :: Connection -> String
describe Disconnected   = "disconnected"
describe (Connecting _) = "connecting"
describe (Connected _)  = "connected"
describe (Failed _)     = "failed"

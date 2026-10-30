-- | The same connection as a sum type: one case per state, each with only
-- the data that state has.
module Connection.States
  ( Connection (..)
  , describe
  , toFlags
  , fromFlags
  ) where

import qualified Connection.Flags as F
import Net

data Connection
  = Disconnected
  | Connecting   RetryCount
  | Connected    Socket
  | Failed       Error
  deriving (Eq, Show)

describe :: Connection -> String
describe Disconnected                  = "disconnected"
describe (Connecting (RetryCount n))   = "connecting, attempt " ++ show n
describe (Connected (Socket fd))       = "connected on socket " ++ show fd
describe (Failed e)                    = "failed: " ++ show e

-- | Every state has a legal record...
toFlags :: Connection -> F.Connection
toFlags Disconnected   = F.Connection False Nothing Nothing
toFlags (Connecting _) = F.Connection False Nothing Nothing
toFlags (Connected s)  = F.Connection True (Just s) Nothing
toFlags (Failed e)     = F.Connection False Nothing (Just e)

-- | ...but going back only works for the legal records.
fromFlags :: F.Connection -> Maybe Connection
fromFlags (F.Connection False Nothing  Nothing)  = Just Disconnected
fromFlags (F.Connection True  (Just s) Nothing)  = Just (Connected s)
fromFlags (F.Connection False Nothing  (Just e)) = Just (Failed e)
fromFlags _                                      = Nothing

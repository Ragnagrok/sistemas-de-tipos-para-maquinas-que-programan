-- | The connection as almost anyone would model it by default:
-- a record with a flag and some optional fields.
module Connection.Flags (Connection (..), shapes, legal) where

import Net

data Connection = Connection
  { isConnected :: Bool
  , socket      :: Maybe Socket
  , lastError   :: Maybe Error
  }
  deriving (Eq, Show)

-- | One representative of each shape: 2 × 2 × 2 = 8.
shapes :: [Connection]
shapes =
  [ Connection c s e
  | c <- [False, True]
  , s <- [Nothing, Just (Socket 3)]
  , e <- [Nothing, Just Timeout]
  ]

-- | Which shapes make sense: disconnected (or connecting: the record can't
-- tell them apart), connected with a socket, or failed with an error.
legal :: Connection -> Bool
legal (Connection False Nothing  Nothing)  = True
legal (Connection True  (Just _) Nothing)  = True
legal (Connection False Nothing  (Just _)) = True
legal _                                    = False

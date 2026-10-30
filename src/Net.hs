-- | The pieces a connection is made of. Kept trivial on purpose.
module Net (Socket (..), Error (..), RetryCount (..)) where

newtype Socket = Socket Int
  deriving (Eq, Show)

data Error = Timeout | Refused
  deriving (Eq, Show)

newtype RetryCount = RetryCount Int
  deriving (Eq, Show)

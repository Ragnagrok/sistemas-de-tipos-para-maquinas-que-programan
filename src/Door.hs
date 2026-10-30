{-# LANGUAGE DataKinds, GADTs, KindSignatures #-}
-- | A protocol as a typed state machine: the door's state lives in its type.
module Door (DoorState (..), Door, newDoor, open, close, isOpen) where

data DoorState = Open | Closed

data Door (s :: DoorState) where
  MkDoor :: Door s                  -- not exported

-- | The only way to get a door: closed.
newDoor :: Door 'Closed
newDoor = MkDoor

open  :: Door 'Closed -> Door 'Open
open MkDoor = MkDoor

close :: Door 'Open   -> Door 'Closed
close MkDoor = MkDoor

-- | Nothing to compute: the answer is in the type.
class IsOpen (s :: DoorState) where isOpen :: Door s -> Bool
instance IsOpen 'Open   where isOpen _ = True
instance IsOpen 'Closed where isOpen _ = False

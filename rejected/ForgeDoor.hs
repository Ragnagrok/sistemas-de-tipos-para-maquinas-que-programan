{-# LANGUAGE DataKinds #-}
-- Make an "open" door out of thin air, skipping the protocol.
-- expects: Data constructor not in scope: MkDoor
module ForgeDoor where

import Door

bad :: Door 'Open
bad = MkDoor

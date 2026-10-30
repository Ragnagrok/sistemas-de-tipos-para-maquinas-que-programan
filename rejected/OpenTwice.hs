{-# LANGUAGE DataKinds #-}
-- Open a door that is already open.
-- expects: Couldn't match type ‘Open’ with ‘Closed’
module OpenTwice where

import Door

bad :: Door 'Open
bad = open (open newDoor)

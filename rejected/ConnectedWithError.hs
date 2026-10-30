-- "Connected and with an error at the same time".
-- expects: The function ‘Connected’ is applied to two visible arguments
module ConnectedWithError where

import Connection.States
import Net

bad :: Connection
bad = Connected (Socket 3) Timeout

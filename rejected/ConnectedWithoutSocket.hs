-- "Connected but without a socket": the record allows it, the sum type doesn't.
-- expects: Couldn't match expected type ‘Connection’
module ConnectedWithoutSocket where

import Connection.States

bad :: Connection
bad = Connected

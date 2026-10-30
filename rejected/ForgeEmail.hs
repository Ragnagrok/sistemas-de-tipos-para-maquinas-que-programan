{-# LANGUAGE OverloadedStrings #-}
-- Build an Email without going through mkEmail. Only the type is exported,
-- so the name Email exists, but not as a constructor.
-- expects: Illegal term-level use of the type constructor ‘Email’
module ForgeEmail where

import Email

bad :: Email
bad = Email "not an email"

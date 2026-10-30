{-# LANGUAGE OverloadedStrings #-}
-- | Parse, don't validate: an 'Email' can only be obtained through 'mkEmail'.
module Email (Email, EmailError (..), mkEmail, emailText) where

import Data.Text (Text)
import qualified Data.Text as T

newtype Email = Email Text          -- the constructor isn't exported
  deriving (Eq, Show)

data EmailError = InvalidEmail
  deriving (Eq, Show)

mkEmail :: Text -> Either EmailError Email
mkEmail t
  | isValid t  = Right (Email t)
  | otherwise  = Left InvalidEmail

emailText :: Email -> Text
emailText (Email t) = t

-- Deliberately simple: one @, something on each side, a dot in the domain.
isValid :: Text -> Bool
isValid t = case T.splitOn "@" t of
  [user, domain] -> not (T.null user) && "." `T.isInfixOf` T.drop 1 domain
  _              -> False

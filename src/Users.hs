{-# LANGUAGE DataKinds, FlexibleContexts, GADTs, TypeOperators #-}
-- | The article's effect example: the type says what the function may do.
module Users
  ( DbConfig (..), NotFound (..), UserId (..), User (..)
  , SendEmail (..), sendEmail
  , fetchUser, runFetchUser
  ) where

import Effects

newtype DbConfig = DbConfig { dbName :: String }
newtype UserId = UserId Int deriving (Eq, Show)
data User = User { userId :: UserId, userName :: String } deriving (Eq, Show)
data NotFound = NotFound UserId deriving (Eq, Show)

-- | An effect that 'fetchUser' does NOT have.
data SendEmail x where
  SendEmail :: String -> String -> SendEmail ()

sendEmail :: Member SendEmail r => String -> String -> Eff r ()
sendEmail to body = send (SendEmail to body)

fetchUser :: Members '[Reader DbConfig, Error NotFound] r
          => UserId -> Eff r User
fetchUser uid@(UserId 1) = do
  cfg <- ask
  pure (User uid ("ada, from " ++ dbName cfg))
fetchUser uid = throwError (NotFound uid)

-- | Run it: provide the configuration, catch the error, nothing else.
runFetchUser :: DbConfig -> UserId -> Either NotFound User
runFetchUser cfg uid = run (runError (runReader cfg (fetchUser uid)))

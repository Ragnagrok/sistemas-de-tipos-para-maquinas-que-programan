{-# LANGUAGE DataKinds, OverloadedStrings #-}
-- | What does compile, and what it prints.
module Main (main) where

import qualified Data.Text as T

import qualified Connection.Flags as F
import qualified Connection.States as S
import Door
import Email
import Net
import Users

main :: IO ()
main = do
  section "The record: 2 x 2 x 2 shapes, few of them legal"
  mapM_ shape F.shapes
  putStrLn ("  " ++ show (length (filter F.legal F.shapes)) ++ " of "
            ++ show (length F.shapes) ++ " shapes are legal")

  section "The sum type: only legal states exist"
  mapM_ (putStrLn . ("  " ++) . S.describe)
    [S.Disconnected, S.Connecting (RetryCount 2), S.Connected (Socket 3), S.Failed Timeout]

  section "Parse, don't validate"
  mapM_ (\t -> putStrLn ("  " ++ show t ++ " -> " ++ either show (T.unpack . emailText) (mkEmail t)))
    ["ada@example.com", "not an email", "@example.com"]

  section "The door: its state is in its type"
  let door = close (open newDoor)
  putStrLn ("  opened and closed again; open now? " ++ show (isOpen door))

  section "Effects in the type"
  print' (runFetchUser (DbConfig "users-db") (UserId 1))
  print' (runFetchUser (DbConfig "users-db") (UserId 2))
  where
    section s = putStrLn ("\n" ++ s)
    print' :: Show a => a -> IO ()
    print' = putStrLn . ("  " ++) . show
    shape c = putStrLn ("  " ++ (if F.legal c then "legal    " else "ILLEGAL  ") ++ show c)

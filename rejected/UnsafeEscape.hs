{-# LANGUAGE Safe #-}
-- The escape hatch: unsafePerformIO would let a "pure" function do I/O.
-- Under Safe Haskell, it can't even be imported.
-- expects: System.IO.Unsafe: Can't be safely imported!
module UnsafeEscape where

import System.IO.Unsafe (unsafePerformIO)

launch :: Int -> Int
launch n = unsafePerformIO (putStrLn "missiles launched" >> pure n)

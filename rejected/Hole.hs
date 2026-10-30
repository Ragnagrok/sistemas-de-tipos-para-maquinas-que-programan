-- A typed hole: leave a _ and ask the compiler what goes there.
-- expects: Found hole: _ :: [Int] -> Int
module Hole where

total :: [Int] -> Int
total xs = _ xs

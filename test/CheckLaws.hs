{-# LANGUAGE ScopedTypeVariables #-}
-- | The laws, checked with QuickCheck. Some properties are expected to hold
-- and some to fail; each one says which.
module Main (main) where

import Control.Monad (unless)
import Data.List (nub)
import qualified Data.Map as Map
import Data.Semigroup (Max (..))
import qualified Data.Set as Set
import Data.Monoid (Sum (..))
import System.Exit (exitFailure)
import Test.QuickCheck

import qualified Connection.Flags as F
import qualified Connection.States as S
import Laws
import Net

instance Arbitrary Socket where arbitrary = Socket <$> arbitrary
instance Arbitrary Error where arbitrary = elements [Timeout, Refused]
instance Arbitrary RetryCount where arbitrary = RetryCount <$> arbitrary
instance Arbitrary S.Connection where
  arbitrary = oneof
    [ pure S.Disconnected
    , S.Connecting <$> arbitrary
    , S.Connected <$> arbitrary
    , S.Failed <$> arbitrary
    ]
instance Arbitrary F.Connection where
  arbitrary = F.Connection <$> arbitrary <*> arbitrary <*> arbitrary
instance Arbitrary Average where
  arbitrary = Average . fromIntegral <$> (arbitrary :: Gen Int)

-- | Should the property hold, or should QuickCheck find a counterexample?
data Expect = Holds | Fails

check :: Testable p => Expect -> String -> p -> IO Bool
check expect name p = do
  r <- quickCheckWithResult stdArgs { chatty = False, maxSuccess = 2000 } p
  let ok = case expect of
        Holds -> isSuccess r
        Fails -> not (isSuccess r)
      verdict = case (expect, isSuccess r) of
        (Holds, True)  -> "holds"
        (Fails, False) -> "fails, as expected: " ++ counter r
        (Holds, False) -> "FAILED: " ++ counter r
        (Fails, True)  -> "HELD, and it shouldn't"
  putStrLn ((if ok then "ok   " else "FAIL ") ++ name ++ ": " ++ verdict)
  pure ok
  where
    counter r = unwords (failingTestCase r)

main :: IO ()
main = do
  results <- sequence
    [ -- Semigroup laws: the instances the article mentions are lawful.
      check Holds "lists: associative" (associative :: [Int] -> [Int] -> [Int] -> Bool)
    , check Holds "Sum Int: associative" (\a b c -> associative (Sum a) (Sum b) (Sum (c :: Int)))
    , check Holds "Max Int: associative" (\a b c -> associative (Max a) (Max b) (Max (c :: Int)))
    , check Holds "Map merge: associative"
        (\a b c -> associative (Map.fromList a) (Map.fromList b) (Map.fromList (c :: [(Int, Char)])))
    , check Holds "Set union: commutative" (\a b -> commutative (Set.fromList a) (Set.fromList (b :: [Int])))
    , check Holds "Set union: idempotent" (\a -> idempotent (Set.fromList (a :: [Int])))
      -- A dictionary merge is a semigroup, but not commutative: Map's (<>)
      -- keeps the left value on a clash. Replicas merged in different orders
      -- would disagree.
    , check Fails "Map merge: commutative"
        (\a b -> commutative (Map.fromList a) (Map.fromList (b :: [(Int, Char)])))
      -- The lawless instance compiles; only the test catches it.
    , check Fails "Average: associative" (associative :: Average -> Average -> Average -> Bool)
      -- Theorems for free: for every function of type [a] -> [a].
    , check Holds "free theorem: reverse" (\xs -> freeTheorem reverse (* (2 :: Int)) (xs :: [Int]))
    , check Holds "free theorem: take 3" (\xs -> freeTheorem (take 3) show (xs :: [Int]))
    , check Holds "free theorem: repeat thrice, take 5"
        (\xs -> freeTheorem (\ys -> take 5 (concat (replicate 3 ys))) even (xs :: [Int]))
      -- nub needs Eq a: with that constraint the free theorem no longer applies.
    , check Fails "nub (Eq a => [a] -> [a]) commutes with map"
        (\xs -> map (`div` (2 :: Int)) (nub xs) == nub (map (`div` 2) (xs :: [Int])))
      -- The two models of a connection.
    , check Holds "every state maps to a legal record"
        (\c -> F.legal (S.toFlags c))
    , check Holds "a record is legal exactly when it maps back to a state"
        (\r -> F.legal r == maybe False (const True) (S.fromFlags r))
    , check Fails "every record is legal" (F.legal :: F.Connection -> Bool)
    ]
  unless (and results) exitFailure

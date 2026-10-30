{-# LANGUAGE RankNTypes #-}
-- | Laws as checkable properties. The compiler checks the types of an
-- instance; the laws it doesn't check, so they become tests.
module Laws
  ( associative, commutative, idempotent
  , Average (..)
  , freeTheorem
  ) where

associative :: (Eq a, Semigroup a) => a -> a -> a -> Bool
associative x y z = (x <> y) <> z == x <> (y <> z)

commutative :: (Eq a, Semigroup a) => a -> a -> Bool
commutative x y = x <> y == y <> x

idempotent :: (Eq a, Semigroup a) => a -> Bool
idempotent x = x <> x == x

-- | A lawless instance: it has the right type, so it compiles,
-- but "combine by averaging" isn't associative.
newtype Average = Average Rational
  deriving (Eq, Show)

instance Semigroup Average where
  Average a <> Average b = Average ((a + b) / 2)

-- | Theorems for free: any function of type @[a] -> [a]@, for every @a@,
-- commutes with 'map'. The type alone guarantees it.
freeTheorem :: Eq b => (forall x. [x] -> [x]) -> (a -> b) -> [a] -> Bool
freeTheorem f g xs = map g (f xs) == f (map g xs)

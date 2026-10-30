{-# LANGUAGE ConstraintKinds, DataKinds, EmptyCase, FlexibleContexts, FlexibleInstances,
             GADTs, KindSignatures, MultiParamTypeClasses, PolyKinds,
             RankNTypes, ScopedTypeVariables, TypeFamilies, TypeOperators #-}
-- | A minimal extensible-effects monad, just enough for the article's
-- signature to compile as written:
--
-- > fetchUser :: Members '[Reader DbConfig, Error NotFound] r
-- >           => UserId -> Eff r User
--
-- The article's syntax is the one of the freer-simple library, which doesn't
-- build on GHC 9.12; this module reproduces its interface in a few lines.
module Effects
  ( Eff, Member, Members
  , send, run
  , Reader, ask, runReader
  , Error, throwError, runError
  , interpret
  ) where

import Data.Kind (Constraint, Type)

-- | An open union: one effect out of the list @r@.
data Union (r :: [Type -> Type]) x where
  Here  :: e x -> Union (e ': r) x
  There :: Union r x -> Union (e ': r) x

class Member (e :: Type -> Type) (r :: [Type -> Type]) where
  inj :: e x -> Union r x
  prj :: Union r x -> Maybe (e x)

instance {-# OVERLAPPING #-} Member e (e ': r) where
  inj = Here
  prj (Here e) = Just e
  prj (There _) = Nothing

instance Member e r => Member e (f ': r) where
  inj = There . inj
  prj (Here _) = Nothing
  prj (There u) = prj u

type family Members (es :: [Type -> Type]) (r :: [Type -> Type]) :: Constraint where
  Members '[] r = ()
  Members (e ': es) r = (Member e r, Members es r)

-- | A program that can perform the effects in @r@.
data Eff (r :: [Type -> Type]) a where
  Pure   :: a -> Eff r a
  Impure :: Union r x -> (x -> Eff r a) -> Eff r a

instance Functor (Eff r) where
  fmap f (Pure a) = Pure (f a)
  fmap f (Impure u k) = Impure u (fmap f . k)

instance Applicative (Eff r) where
  pure = Pure
  Pure f <*> m = fmap f m
  Impure u k <*> m = Impure u ((<*> m) . k)

instance Monad (Eff r) where
  Pure a >>= f = f a
  Impure u k >>= f = Impure u ((>>= f) . k)

send :: Member e r => e x -> Eff r x
send e = Impure (inj e) Pure

-- | Only a program with no effects left can be run purely.
run :: Eff '[] a -> a
run (Pure a) = a
run (Impure u _) = case u of {}

-- | Handle the first effect of the list.
interpret :: (forall x. e x -> (x -> Eff r a) -> Eff r a) -> Eff (e ': r) a -> Eff r a
interpret _ (Pure a) = Pure a
interpret h (Impure (Here e) k) = h e (interpret h . k)
interpret h (Impure (There u) k) = Impure u (interpret h . k)

data Reader i x where
  Ask :: Reader i i

ask :: Member (Reader i) r => Eff r i
ask = send Ask

runReader :: i -> Eff (Reader i ': r) a -> Eff r a
runReader i = interpret (\Ask k -> k i)

data Error e x where
  Throw :: e -> Error e x

throwError :: Member (Error e) r => e -> Eff r a
throwError = send . Throw

runError :: Eff (Error e ': r) a -> Eff r (Either e a)
runError (Pure a) = Pure (Right a)
runError (Impure (Here (Throw e)) _) = Pure (Left e)
runError (Impure (There u) k) = Impure u (runError . k)

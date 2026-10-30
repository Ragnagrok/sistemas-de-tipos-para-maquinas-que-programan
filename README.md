# Type Systems for Machines That Program

Proof of concept for the article *Type Systems for Machines That Program*
([English](https://blog.ragnagrok.com/en/2026-06-18-sistemas-de-tipos-para-maquinas-que-programan) ·
[español](https://blog.ragnagrok.com/es/2026-06-18-sistemas-de-tipos-para-maquinas-que-programan)):
the article's Haskell examples, made to compile, run and fail where they should.

The idea in one line: a type checker is fast, total and deterministic, so every error that
moves from run time to compile time is an error an agent gets told about in milliseconds.
Here each claim of the article is either a program that compiles or a file that doesn't,
with the exact error it gets.

## What's here

| File | What it shows |
|---|---|
| `src/Connection/Flags.hs` | The connection as a record with a flag and two optional fields. `shapes` lists its 2 × 2 × 2 = 8 shapes; only 3 are legal. |
| `src/Connection/States.hs` | The same connection as a sum type. `fromFlags` maps a record back to a state, and succeeds exactly for the legal ones. |
| `src/Email.hs` | *Parse, don't validate*: the `Email` constructor isn't exported, so `mkEmail` is the only way in. |
| `src/Door.hs` | A protocol as a typed state machine: `open :: Door 'Closed -> Door 'Open`. |
| `src/Effects.hs`, `src/Users.hs` | Effects in the type: `fetchUser :: Members '[Reader DbConfig, Error NotFound] r => UserId -> Eff r User`, exactly as in the article. |
| `src/Laws.hs`, `test/CheckLaws.hs` | Semigroup laws and a free theorem, checked with QuickCheck. |
| `examples/Main.hs` | What does compile, and what it prints (`cabal run demo`). |
| `rejected/*.hs` | What does **not** compile, each with the error it expects on its `-- expects:` line. |

The rejected ones:

- `ConnectedWithoutSocket.hs`: "connected but without a socket". `Couldn't match expected type ‘Connection’`.
- `ConnectedWithError.hs`: "connected and failed at the same time". `Connected` takes a socket and nothing else.
- `ForgotReconnecting.hs`: a `Reconnecting` state is added and a function forgets it. `Pattern match(es) are non-exhaustive` (with `-Werror=incomplete-patterns`).
- `ForgeEmail.hs`: build an `Email` without `mkEmail`. Only the type is exported.
- `OpenTwice.hs`: open a door that's already open. `Couldn't match type ‘Open’ with ‘Closed’`.
- `ForgeDoor.hs`: make an open door out of thin air. `MkDoor` isn't exported.
- `SneakEmail.hs`: `fetchUser` tries to send an email. `Could not deduce ‘Member SendEmail r’`.
- `Hole.hs`: a typed hole. The compiler answers `Found hole: _ :: [Int] -> Int` and lists what fits.
- `UnsafeEscape.hs`: the escape hatch `unsafePerformIO`. Under Safe Haskell it can't be imported.

What the law tests show (`cabal test`):

- Lists, `Sum`, `Max` and `Map` merging are associative, as the article says.
- A lawless `Semigroup` (combining by averaging) **compiles**: the compiler checks the type of
  `(<>)`, not its law. QuickCheck finds the counterexample.
- `Map` merging is associative but **not commutative** (on a key clash the left value wins), so
  merging replicas in different orders would disagree. `Set` union is commutative and idempotent.
- The free theorem: any `f :: [a] -> [a]` commutes with `map`. `nub :: Eq a => [a] -> [a]` doesn't,
  because the `Eq` constraint lets it look at the elements.

## Running it

With GHC 9.12 and cabal:

```sh
./check.sh       # builds, runs the example and the law tests, and checks that the rejected files fail for the stated reason
cabal run demo   # the example that does compile
cabal test       # the law tests
```

## What this proof of concept doesn't cover

- **The effect system is a minimal one, written here.** The article's signature uses the
  syntax of the [freer-simple](https://hackage.haskell.org/package/freer-simple) library, which
  doesn't build on GHC 9.12. `src/Effects.hs` reimplements just enough of its interface (`Eff`,
  `Member`, `Members`, `Reader`, `Error`) in about a hundred lines.
- **No refinement or dependent types.** Liquid Haskell, Idris, Agda and Dafny are mentioned in
  the article and left out here.
- **No session types.** The door is a two-state protocol; session types extend the idea to a
  whole conversation between services.
- **The shapes are shapes.** "2 × 2 × 2" counts which fields are set, not values: each `Just`
  carries a socket or an error, so the record has many more values, and the illegal ones among
  them are just as many more.
- **The record is also too small.** It can't tell `Disconnected` from `Connecting`: both are
  `Connection False Nothing Nothing`, and the retry count has nowhere to go.

## Further reading

- Minsky (2011), [*Effective ML Revisited*](https://blog.janestreet.com/effective-ml-revisited/): *make illegal states unrepresentable*.
- King (2019), [*Parse, don't validate*](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/).
- Wadler (1989), [*Theorems for Free!*](https://doi.org/10.1145/99370.99404).
- Claessen and Hughes (2000), [*QuickCheck: A Lightweight Tool for Random Testing of Haskell Programs*](https://doi.org/10.1145/351240.351266).
- Shapiro, Preguiça, Baquero and Zawirski (2011), [*Conflict-Free Replicated Data Types*](https://doi.org/10.1007/978-3-642-24550-3_29).
- Honda, Vasconcelos and Kubo (1998), [*Language Primitives and Type Discipline for Structured Communication-Based Programming*](https://doi.org/10.1007/BFb0053567): session types.
- Wlaschin (2018), [*Domain Modeling Made Functional*](https://pragprog.com/titles/swdddf/domain-modeling-made-functional/).

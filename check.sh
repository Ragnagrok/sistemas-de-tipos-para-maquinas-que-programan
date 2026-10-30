#!/usr/bin/env bash
# Builds everything, runs the example and the law tests, and checks that every
# file in rejected/ fails with the error announced on its "-- expects:" line.
set -euo pipefail
cd "$(dirname "$0")"

cabal build all --enable-tests -v0
echo "ok   the library, examples/Main.hs and the tests compile"

cabal run demo -v0 >/dev/null
echo "ok   examples/Main.hs runs"

cabal test -v0 --test-show-details=direct

out=$(mktemp -d)
trap 'rm -rf "$out"' EXIT
failures=0
for f in rejected/*.hs; do
  expected=$(sed -n 's/^-- expects: //p' "$f")
  if output=$(ghc -XHaskell2010 -fno-code -isrc -outputdir "$out" "$f" 2>&1); then
    echo "FAIL $f compiled, and it shouldn't"; failures=1
  elif grep -qF "$expected" <<<"$output"; then
    echo "ok   $f doesn't compile: $expected"
  else
    echo "FAIL $f doesn't compile, but not for the expected reason:"; echo "$output"; failures=1
  fi
done
exit $failures

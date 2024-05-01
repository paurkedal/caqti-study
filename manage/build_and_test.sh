#!/bin/bash

set -e

echo "==> Removing old switch..."
opam switch default
opam switch --yes remove caqti-study
eval $(opam env)

echo "==> Recreating custom switch..."
opam switch create caqti-study 5.1.1
eval $(opam env --switch=caqti-study)

echo "==> Installing ppx_rapper pins..."
opam pin add --yes git+https://github.com/roddyyaga/ppx_rapper#2222edbbe68db7ba1ab0c7a2688c227ea5c0f230

echo "==> Installing other dependencies..."
opam install . --deps-only --yes

echo "==> Running the tests..."
PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune runtest -j1

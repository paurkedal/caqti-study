# Hello, caqti-eio!

Let's look at [eio](https://github.com/ocaml-multicore/eio)!

Instead of promises, we will instead use a "direct style" concurrency model.

> NOTE: OCaml v5 or greater is required.

As always let's run our tests:

```
cd ./hello-caqti-eio
PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune exec ./bin/main.exe
PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune runtest --watch
```

## Test via the REPL


```
$ PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune utop
```

Let's bring the `Init` and `Exec` modules into scope:
```ocaml
# open Repo
```

Now let's query the database!

Unlike previously, we have to conform to a callback style. See the [Exec](./lib/repo/exec.ml) module for more info.
```ocaml
# Init.with_conn (fun conn -> Exec.add conn 1 2) |> Result.get_ok;;
- : int = 3
```

Let's follow this up with a second example:
1. We adjust the syntax for easier REPL interactions.
2. We use the simpler `with_conn'` function (see the [Exec](./lib/repo/exec.ml) module for more info)

---

FIXME: This works in the REPL, not with mdx.
FIXME: Usually, I manage to work around similar issues by adding more dependencies to the mdx project's dune file.
FIXME: And/or open a few imports within the mdx context. But not this time.

```ocaml
# Result.get_ok @@ Init.with_conn' @@ fun conn -> Repo.Exec.mul conn 3 4;;
Line 1, characters 63-67:
Error: This expression has type Caqti_eio.connection
       but an expression was expected of type (module Caqti_eio.CONNECTION)
       Caqti_eio.connection is abstract because no corresponding cmi file was found in path.
```

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

Firstly, let's bring the `Init` and `Exec` modules into scope:
```ocaml
# open Repo
```

Let's also define a variant of `with_conn` which is fused with Eio_main.run, for convenience when using the toplevel.

```ocaml
# let run_with_conn f = Caqti_eio.or_fail @@ Eio_main.run @@ fun env -> Init.with_conn f ~stdenv:(env :> Caqti_eio.stdenv)
val run_with_conn :
  (Caqti_eio.connection ->
   ('a,
    [< Caqti_error.t
     > `Connect_failed `Connect_rejected `Load_failed `Load_rejected
       `Post_connect ])
   result) ->
  'a = <fun>
```

> NOTE: we use the `:>` operator to force a type coercion between the more general `Eio_unix.Stdenv.base` type, to the more specific (but still compatible) `Caqti_eio.stdenv` type.

Now we can query the database!

```ocaml
# run_with_conn @@ Exec.add 1 2;;
- : int = 3
```

Here's the fully expanded version for clarity:

```ocaml
# Caqti_eio.or_fail @@ Eio_main.run @@ fun env -> Init.with_conn ~stdenv:(env :> Caqti_eio.stdenv) @@ fun conn -> Exec.mul 3 4 conn;;
- : int = 12
```

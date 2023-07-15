# Hello, caqti-blocking!

Now, we will talk to our database sequentially with `caqti`, via its "blocking" module.

We will gain the following abilities:

- talk to our database via a REPL (calling into our lib)
- talk to our database via starting our application (`bin/main.ml`)
- validate that our code always works by implementing some tests

We introduce 2 functions inside the `Init` module:

- `connect ()`, which returns either a "connection module", or an error
- `connect_exn ()` which returns a "connection module" and fails at runtime if something's wrong
    - we will use this function in the REPL sessions.

NOTE:

From now on, our library's name changes to `repo`. This communicates the fact that its only job will be to talk to the database.
While this library code could reside inside the `lib/` folder itself, we will move it to `lib/repo/`. This will make introducing new (internal) libraries easier, later.

The test folder will mirror this change.

NOTE:

We also introduce an `init.mli` file. Any function listed in this file will be public/exported. The REPL wont't be able to call any private functions (good!).

```
cd ./02-hello-caqti
PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune exec ./bin/main.exe
PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune dune runtest --watch
```

## A note on error handling

Here, we introduce the concepts of monads.

To make a long story short, monads allow us to reduce this kind of nesting:

```ocaml
let add a b c =
  match a with
  | None -> None
  | Some x -> (
      match b with
      | None -> None
      | Some y -> (
          match c with
          | None -> None
          | Some z -> Some (x + y + z)))
```

To reduce repetition, we can defer to `bind` which encapsulates the pattern "stop on fail, otherwise continue".

It's a little bit like JavaScript's promises.

```ocaml
let add a b c =
  Option.bind a (fun x ->
    Option.bind b (fun y ->
      Option.bind c (fun z ->
        Some (x + y + z)
      )
    )
  )
```

We can reduce the nesting further by assigning `bind` to the `>>=` operator:

```ocaml
let ( >>= ) = Option.bind
let add a b c =
  a >>= fun x ->
  b >>= fun y ->
  c >>= fun z ->
  Some(x + y +z )
```

To make things read more naturally, we can also introduce a special "let operator". This is a more recent capability of OCaml and we will favor using this syntax.

This feature is a little similar in spirit to JavaScript's async syntax.

```ocaml
let ( let* ) = Option.bind

let add a b c =
  let* x = a in
  let* y = b in
  let* z = c in
  Some (x + y + z)
```

We can apply this pattern to other types, such as `Result`, but also `Lwt` which we will talk about in the next example.
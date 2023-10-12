# Hello, caqti-async!

Let's have a look at `Caqti`'s `async` module.

Same as before, we'll have to cross 2 contexts:


```mermaid
flowchart RL
    Async --> Result
    Result --> Data
```


```
# Load the project
$ PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune utop
```

While we could define a `let operator`, as we did with `lwt`:

```ocaml
# open Async;;

# let ( let* ) t f = Deferred.bind t ~f;;
val ( let* ) : 'a Deferred.t -> ('a -> 'b Deferred.t) -> 'b Deferred.t =
  <fun>

# let future_work1 =
    let* result = Deferred.return (Ok 1) in
    Deferred.return result;;
val future_work1 : (int, 'a) result Deferred.t = <abstr>

# Thread_safe.block_on_async_exn @@ fun () -> future_work1;;
- : (int, 'a) result = Ok 1
```

`async` actually comes with 2 builtin syntaxes:

 - "ppx" let-bindings
 - operators

> A ppx basically is OCaml's way to do meta-programming.

So instead we will use this syntax:

```ocaml
# #require "ppx_let";;

# let future_work2 : (int, 'a) result Deferred.t =
    let%bind result = Deferred.return (Ok 2) in
    Deferred.return result;;
val future_work2 : (int, 'a) result Deferred.t = <abstr>

# Thread_safe.block_on_async_exn @@ fun () -> future_work2;;
- : (int, 'a) result = Ok 2
```

Or this syntax:

```ocaml
# #require "core";;
# let future_work3 : (int, 'a) Result.t Deferred.t =
    Deferred.return (Ok 3) >>=? fun number ->
    Deferred.return (Ok number)
val future_work3 : (int, 'a) result Deferred.t = <abstr>

# Thread_safe.block_on_async_exn @@ fun () -> future_work3;;
- : (int, 'a) result = Result.Ok 3
```

An important pattern to remember is that `map` = `bind` + `return`, so we can simplify this further:

```ocaml
# let future_work4 : (int, 'a) Result.t Deferred.t =
    let open Async.Deferred.Result.Let_syntax in
    let%map number = Deferred.return (Ok 4) in
    number
val future_work4 : (int, 'a) result Deferred.t = <abstr>

# Thread_safe.block_on_async_exn @@ fun () -> future_work4;;
- : (int, 'a) result = Result.Ok 4


# let future_work5 : (int, 'a) Result.t Deferred.t =
    let open Async in
    Deferred.return (Ok 5) >>|? fun number -> number
val future_work5 : (int, 'a) result Deferred.t = <abstr>

# Thread_safe.block_on_async_exn @@ fun () -> future_work5;;
- : (int, 'a) result = Result.Ok 5
```

See the tests for more details.

```
cd ./04-hello-caqti-async
PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune exec ./bin/main.exe
PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune runtest --watch
```

```ocaml
# open Repo;;
# let conn = Init.connect_exn ();;
val conn : (module Caqti_async.CONNECTION) = <module>

# let future_add = Exec.add conn 1 2;;
val future_add : (int, [> Caqti_error.call_or_retrieve ]) result Deferred.t =
  <abstr>

# open Async;;
# Thread_safe.block_on_async_exn @@ fun () -> future_add;;
- : (int, [> Caqti_error.call_or_retrieve ]) result = Ok 3
```

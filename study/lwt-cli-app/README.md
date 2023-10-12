# Lwt CLI app

Now, that we have acquired enough knowledge, we will build the app mentioned in the main `README`. The user will generate CRUD queries via a CLI.

In the `async` example, we saw that that `map` = `bind` + `return`.

This general concept is also applicable to `lwt`, so we will make use of it via the `Lwt_result.Syntax` module:

- `let*` stands for bind
- `let+` stands for map

> NOTE: learning about `async` isn't required to understand `lwt`, but you may find value in playing with that example, to get the bigger picture.

Here's an example illustrating different syntax variations: we always return a `result` wrapped in a `lwt` promise.

```ocaml
module Init = Repo.Init
module Author = Repo.Author

open Lwt_result.Syntax

let will_get_author_v1 () : ('author, 'error) result Lwt.t =
  let* conn = Init.connect () in
  let* author = Author.find_by_id conn 1 in
  Lwt.return (Ok author)

let will_get_author_v2 () : ('author, 'error) result Lwt.t =
  let* conn = Init.connect () in
  let* author = Author.find_by_id conn 1 in
  Lwt.return_ok author

let will_get_author_v3 () : ('author, 'error) result Lwt.t =
  let* conn = Init.connect () in
  Lwt.map (fun author -> author) (Author.find_by_id conn 1)

let will_get_author_v4 () : ('author, 'error) result Lwt.t =
  let* conn = Init.connect () in
  let+ author = Author.find_by_id conn 1 in
  author

let will_get_author_v5 () : ('author, 'error) result Lwt.t =
  let* conn = Init.connect () in
  Author.find_by_id conn 1
```

```
cd ./05-lwt-cli-app
PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune exec ./bin/simple.exe
PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune runtest --watch
```

As before, we can fully interact with our app via the REPL

```
$ cd ./05-lwt-cli-app
$ make -C .. db-reset && PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune utop
utop # open Repo;;
utop # let conn = Init.connect_exn ();;
utop # Init.create_tables conn;;
utop # Init.seed conn;;
utop # Bibliography.ls conn;;
utop # Author.insert conn { first_name = "John"; last_name = "Doe"; middle_name = None };;
```

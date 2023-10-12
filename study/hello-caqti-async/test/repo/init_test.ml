(*
  Run with one of:

    - PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune runtest --watch
    - PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune build @all @runtest --watch
 *)

module Deferred = Async.Deferred

(** A helper function that communicates our intention to run the test async
  *)
let async_test = Async.Thread_safe.block_on_async_exn

let%test_unit "OCaml: add" =
  let ( => ) = [%test_eq: Base.int] in
  1 + 2 => 3;
  2 + 3 => 5

let%test_unit _ =
  let ( => ) = [%test_eq: Base.string Base.list] in
  async_test @@ fun () ->
  let open Async.Deferred.Let_syntax in
  let%map lines = Async.Reader.file_lines "hello.txt" in
  lines => [ "Hello"; "World" ]

(** Override the Caqti error case to [string], to make specifying testing expectations easier *)
let str_error fut = Deferred.map fut ~f:(Result.map_error Caqti_error.show)

let%test_unit "PostgreSQL: add (asynchronously, style 1)" =
  let ( => ) = [%test_eq: (Base.int, Base.string) Base.Result.t] in
  async_test @@ fun () ->
  let open Async.Deferred.Let_syntax in
  match%bind Repo.Init.connect () |> str_error with
  | Error err -> Deferred.return (failwith err)
  | Ok conn ->
      let%bind sum_res = Repo.Exec.add conn 1 2 |> str_error in
      Deferred.return (sum_res => Ok 3)

let%test_unit "PostgreSQL: add (asynchronously, style 2)" =
  let ( => ) = [%test_eq: (Base.int, Base.string) Base.Result.t] in
  async_test @@ fun () ->
  let open Async.Deferred.Result.Let_syntax in
  let will_add a b =
    let%bind conn = Repo.Init.connect () |> str_error in
    Repo.Exec.add conn a b |> str_error
  in
  will_add 1 2 |> Deferred.map ~f:(fun sum -> sum => Ok 3)

let%test_unit "PostgreSQL: add (asynchronously, style 3)" =
  let ( => ) = [%test_eq: (Base.int, Base.string) Base.Result.t] in
  async_test @@ fun () ->
  let open Async in
  let will_add a b : (int, string) result Deferred.t =
    Repo.Init.connect () |> str_error >>=? fun conn ->
    Repo.Exec.add conn a b |> str_error
  in
  will_add 1 2 >>| fun sum -> sum => Ok 3

let%test_unit "PostgreSQL: add (asynchronously, style 4)" =
  let fn () =
    let ( => ) = [%test_eq: (Base.int, Base.string) Base.Result.t] in
    let will_add a b : (int, string) Deferred.Result.t =
      let ( let* ) t f = Deferred.Result.bind t ~f in
      let* conn = Repo.Init.connect () |> str_error in
      let ( let* ) t f = Deferred.map t ~f in
      let* sum = Repo.Exec.add conn a b |> str_error in
      sum
    in
    will_add 1 2 |> Deferred.map ~f:(fun sum -> sum => Ok 3)
  in
  Async.Thread_safe.block_on_async_exn fn

let%test_unit "PostgreSQL: add (asynchronously, just for fun)" =
  let ( => ) = [%test_eq: (Base.int, Base.string) Base.Result.t] in
  let add_async a b expected =
    async_test @@ fun () ->
    let open Async in
    let will_add a b : (int, string) result Deferred.t =
      Repo.Init.connect () |> str_error >>=? fun conn ->
      Repo.Exec.add conn a b |> str_error
    in
    will_add a b >>| expected
  in
  add_async 1 1 (fun sum -> sum => Ok 2);
  add_async 2 3 (fun sum -> sum => Ok 5);
  add_async 5 8 (fun sum -> sum => Ok 13);
  ()

(*

Note that you may also use `ppx_expect` which has the benefit of allowing testing async functions without
introducing the `Async.Thread_safe.block_on_async_exn` function.

For this to work, you need to open Async globally, and add these 2 dependencies:

- ppx_expect
- ppx_sexp_conv

 *)

open Async
open Base

let%expect_test _ =
  let%map lines = Reader.file_lines "hello.txt" in
  print_s @@ [%sexp_of: string list] lines;
  [%expect {| (Hello World) |}]

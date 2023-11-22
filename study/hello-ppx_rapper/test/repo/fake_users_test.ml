(*
  Run with one of:

    - PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune runtest --watch
    - PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune build @all @runtest --watch
 *)

let str_error promise =
  Lwt.bind promise (fun res ->
      res |> Result.map_error Caqti_error.show |> Lwt.return)

let%test_unit "Get a number" =
  let ( => ) = [%test_eq: (Base.int, Base.string) Base.Result.t] in
  let promise_number ~offset =
    let ( let* ) = Lwt_result.bind in
    let* conn = Repo.Init.connect () |> str_error in
    Repo.Fake_users.forty_two ~offset conn |> str_error
  in
  Lwt_main.run (promise_number ~offset:0) => Ok 42;
  Lwt_main.run (promise_number ~offset:1) => Ok 43;
  ()

let%test_unit "Get a series" =
  let ( => ) = [%test_eq: (Base.int Base.list, Base.string) Base.Result.t] in
  let promise_series =
    let ( let* ) = Lwt_result.bind in
    let* conn = Repo.Init.connect () |> str_error in
    Repo.Fake_users.series () conn |> str_error
  in
  Lwt_main.run promise_series => Ok [ 1; 2; 3; 4; 5 ]

let%test_unit "Get a series with an offset" =
  let ( => ) = [%test_eq: (Base.int Base.list, Base.string) Base.Result.t] in
  let promise_series ~shift =
    let ( let* ) = Lwt_result.bind in
    let* conn = Repo.Init.connect () |> str_error in
    Repo.Fake_users.series' ~shift conn |> str_error
  in
  Lwt_main.run (promise_series ~shift:0) => Ok [ 1; 2; 3; 4; 5 ];
  Lwt_main.run (promise_series ~shift:1) => Ok [ 2; 3; 4; 5; 6 ]

open Sexplib.Std

(* We duplicate the Repo.Fake_users.user type here for 2 reasons:
 * 1. We don't want to inject sexp derivation code into or non-test code (yet).
 * 2. The attribute [is_account_active] is randomly true or false, so we can't test this value.
 *)
type test_user = { user_id : int; email : string } [@@deriving sexp, ord]

let similar (u : Repo.Fake_users.user) : test_user =
  { user_id = u.user_id; email = u.email }

let%test_unit "Get a fake user list" =
  let ( => ) = [%test_eq: (test_user Base.list, Base.string) Base.Result.t] in
  let promise_users =
    let ( let* ) = Lwt_result.bind in
    let* conn = Repo.Init.connect () |> str_error in
    let* (users : Repo.Fake_users.user list) =
      Repo.Fake_users.fake_users () conn |> str_error
    in
    Lwt.return_ok (List.map similar users)
  in
  Lwt_main.run promise_users
  => Ok
       [
         { user_id = 1; email = "user1@example.com" };
         { user_id = 2; email = "user2@example.com" };
         { user_id = 3; email = "user3@example.com" };
         { user_id = 4; email = "user4@example.com" };
         { user_id = 5; email = "user5@example.com" };
       ]

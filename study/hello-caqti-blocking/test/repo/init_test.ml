(*
  Run with one of:

    - PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune runtest --watch
    - PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune build @all @runtest --watch
 *)

let%test_unit "OCaml: 1+2=3" =
  let ( => ) = [%test_eq: Base.int] in
  1 + 2 => 3

let%test_unit "PostgreSQL: 1+2=3 (verbose, not functional)" =
  let ( => ) = [%test_eq: Base.int] in
  let db_add a b =
    match Repo.Init.connect () with
    | Error _ -> failwith "could not connect!"
    | Ok conn -> (
        match Repo.Exec.add conn a b with
        | Error _ -> failwith "could not execute 'add'"
        | Ok n -> n)
  in
  db_add 1 2 => 3

let or_fail msg result =
  match result with
  | Error _ -> failwith ("could not execute: " ^ msg)
  | Ok v -> v

let%test_unit "PostgreSQL: 1+2=3 (terser, not functional)" =
  let ( => ) = [%test_eq: Base.int] in
  let conn = Repo.Init.connect () |> or_fail "connect" in
  let db_add a b = Repo.Exec.add conn a b |> or_fail "add" in
  db_add 1 2 => 3

let%test_unit "PostgreSQL: 1+2=3 (verbose, functional)" =
  let ( => ) = [%test_eq: (Base.int, Base.string) Base.Result.t] in
  let db_add a b =
    match Repo.Init.connect () with
    | Error _ -> Error "could not connect!"
    | Ok conn -> (
        match Repo.Exec.add conn a b with
        | Error _ -> Error "could not execute 'add'"
        | Ok n -> Ok n)
  in
  db_add 1 2 => Ok 3

let%test_unit "PostgreSQL: 1+2=3 (terser, functional)" =
  let ( => ) = [%test_eq: (Base.int, Base.string) Base.Result.t] in
  let db_add a b =
    let ( let* ) = Result.bind in
    let* conn = Repo.Init.connect () |> Result.map_error (fun _ -> "connect") in
    Repo.Exec.add conn a b |> Result.map_error (fun _ -> "add")
  in
  db_add 1 2 => Ok 3

let%test_unit "PostgreSQL: 1+2=3 (terser alternative, functional)" =
  let ( => ) = [%test_eq: (Base.int, Base.string) Base.Result.t] in
  let db_add a b =
    let ( >>= ) = Result.bind in
    Repo.Init.connect () |> Result.map_error (fun _ -> "connect")
    >>= fun conn -> Repo.Exec.add conn a b |> Result.map_error (fun _ -> "add")
  in
  db_add 1 2 => Ok 3

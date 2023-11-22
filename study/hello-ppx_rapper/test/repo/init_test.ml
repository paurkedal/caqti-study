(*
  Run with one of:

    - PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune runtest --watch
    - PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune build @all @runtest --watch
 *)

let%test_unit "OCaml: add" =
  let ( => ) = [%test_eq: Base.int] in
  1 + 2 => 3;
  2 + 3 => 5

let str_error promise =
  Lwt.bind promise (fun res ->
      res |> Result.map_error Caqti_error.show |> Lwt.return)

let%test_unit "PostgreSQL: add with ppx_rapper over lwt" =
  let ( => ) = [%test_eq: (Base.int, Base.string) Base.Result.t] in
  let will_add a b =
    let ( let* ) = Lwt_result.bind in
    let* conn = Repo.Init.connect () |> str_error in
    Repo.Exec.add ~a ~b conn |> str_error
  in
  Lwt_main.run (will_add 1 2) => Ok 3;
  Lwt_main.run (will_add 2 3) => Ok 5

(*
  Run with one of:

    - PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune runtest --watch
    - PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune build @all @runtest -j1 --watch
 *)

let%test_unit "PostgreSQL: add (asynchronously)" =
  let ( => ) = [%test_eq: (Base.int, Base.string) Base.Result.t] in
  let will_add a b =
    Repo.Init.with_conn (fun conn -> Repo.Exec.add conn a b)
    |> Result.map_error Caqti_error.show
  in
  will_add 1 2 => Ok 3;
  will_add 2 3 => Ok 5;
  ()

let%test_unit "PostgreSQL: multiply (asynchronously)" =
  let ( => ) = [%test_eq: (Base.int, Base.string) Base.Result.t] in
  let will_mul a b =
    Repo.Init.with_conn (fun conn -> Repo.Exec.mul conn a b)
    |> Result.map_error Caqti_error.show
  in
  will_mul 2 3 => Ok 6;
  will_mul 3 4 => Ok 12;
  ()

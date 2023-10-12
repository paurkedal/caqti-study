(*
  Run with:

    PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune exec ./bin/main.exe
*)

let add_with_db1 () =
  Result.bind (Repo.Init.connect ()) (fun conn ->
      Result.bind (Repo.Exec.add conn 1 2) (fun n -> Ok n))

let add_with_db2 () =
  let ( let* ) = Result.bind in
  let* conn = Repo.Init.connect () in
  let* n = Repo.Exec.add conn 1 2 in
  Ok n

let () =
  match add_with_db1 () with
  | Error err ->
      print_endline "We encountered an error while executing add_with_db1";
      print_endline (Caqti_error.show err)
  | Ok n -> Printf.printf "1) DB says 1+2=%d\n" n

let () =
  match add_with_db2 () with
  | Error err ->
      print_endline "We encountered an error while executing add_with_db2";
      print_endline (Caqti_error.show err)
  | Ok n -> Printf.printf "2) DB says 1+2=%d\n" n

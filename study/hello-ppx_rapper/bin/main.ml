(*
  Run with:

    PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune exec ./bin/main.exe
*)

let will_add a b : (int, 'err) result Lwt.t =
  let ( let* ) = Lwt_result.bind in
  let* conn = Repo.Init.connect () in
  Repo.Exec.add ~a ~b conn

let () =
  match Lwt_main.run (will_add 1 2) with
  | Error err ->
      print_endline "Oops, we encountered an error!";
      print_endline (Caqti_error.show err)
  | Ok n -> Printf.printf "DB says 1+2=%d (with ppx_rapper!)\n" n

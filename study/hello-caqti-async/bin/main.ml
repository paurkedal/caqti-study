(*
  Run with:

    PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune exec ./bin/main.exe
*)

open Async

let will_add a b : (int, 'err) result Deferred.t =
  Repo.Init.connect () >>=? fun conn ->
  Repo.Exec.add conn a b >>| fun res -> res

let run_async () =
  match%bind will_add 1 2 with
  | Error err ->
      print_endline "Oops, we encountered an error!";
      print_endline (Caqti_error.show err) |> Deferred.return
  | Ok n -> printf "DB says 1+2=%d\n" n |> Deferred.return

let () =
  let command : Command.t =
    Async.Command.async ~summary:"My command line app"
      (Command.Param.return run_async)
  in
  Command_unix.run command

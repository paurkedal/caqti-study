(*
  Run with:

    PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune exec ./bin/main.exe

  ---

  In eio, we need to send a "switch" to the callee. This can enable it to do,
  among other things, resources cleanup, message cancellation, etc.

  Typically, we want to do this right at the start of your application, so not
  as a library call.
*)

open Printf
module Init = Repo.Init
module Exec = Repo.Exec

type data = { sum : int; product : int }

let main (env : Eio_unix.Stdenv.base) =
  let ( let* ) = Result.bind in
  let program : (data, 'err) result =
    Init.with_conn ~stdenv:(env :> Caqti_eio.stdenv) @@ fun conn ->
    let* sum = Exec.add 1 2 conn in
    let* product = Exec.mul 3 4 conn in
    Ok { sum; product }
  in

  match program with
  | Error e -> failwith (sprintf "Got error! %s" (Caqti_error.show e))
  | Ok { sum; product } ->
      print_endline "Program ran successfully!";
      printf "DB said: 1+2=%d and 3*4=%d\n" sum product

let () = Eio_main.run main

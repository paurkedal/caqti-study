(*
  Run with:

    PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune exec ./bin/main.exe
*)

open Printf
module Init = Repo.Init
module Exec = Repo.Exec

type data = { sum : int; product : int }

let () =
  let ( let* ) = Result.bind in
  let program : (data, 'err) result =
    (* We could also use the simpler [Init.with_conn'] function here *)
    Init.with_conn @@ fun conn ->
    let* sum = Exec.add conn 1 2 in
    let* product = Exec.mul conn 3 4 in
    Ok { sum; product }
  in
  match program with
  | Error e -> failwith (sprintf "Got error! %s" (Caqti_error.show e))
  | Ok { sum; product } ->
      print_endline "Program ran successfully!";
      printf "DB said: 1+2=%d and 3*4=%d\n" sum product

(* module `Q` contains our query definitions *)
module Q = struct
  open Caqti_request.Infix

  (*
    Caqti infix operators

    ->! decodes a single row
    ->? decodes zero or one row
    ->* decodes many rows
    ->. expects no row
  *)

  (* `add` takes 2 ints (as a tuple), and returns 1 int *)
  let add =
    Caqti_type.(tup2 int int ->! int)
    "SELECT ? + ?"
  [@@ocamlformat "disable"]
end

(* Now we use our query definitions *)

(*
   $ PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune utop
   utop # open Repo;;
   utop # let conn = Init.connect_exn ();;
   utop # Exec.add conn 1 2;;
   - : (int, [> Caqti_error.call_or_retrieve ]) result = Ok 3
 *)
let add (module Conn : Caqti_async.CONNECTION) a b =
  Conn.find Q.add (a, b)
[@@ocamlformat "disable"]

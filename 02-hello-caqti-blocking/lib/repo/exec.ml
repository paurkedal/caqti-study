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

let add (module Conn : Caqti_blocking.CONNECTION) a b =
  Conn.find Q.add (a, b)
[@@ocamlformat "disable"]

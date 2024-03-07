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
    Caqti_type.(t2 int int ->! int)
    "SELECT ? + ?"
  [@@ocamlformat "disable"]

  let mul =
    Caqti_type.(t2 int int ->! int)
    "SELECT ? * ?"
  [@@ocamlformat "disable"]
end

(* Now we use our query definitions *)

let add a b (conn : Caqti_eio.connection) =
  (* If you don't understand this line, refer to: study/hello-caqti-blocking/lib/repo/exec.ml *)
  let module Conn = (val conn : Caqti_eio.CONNECTION) in
  Conn.find Q.add (a, b)
  [@@ocamlformat "disable"]

let mul a b (module Conn : Caqti_eio.CONNECTION) = Conn.find Q.mul (a, b)

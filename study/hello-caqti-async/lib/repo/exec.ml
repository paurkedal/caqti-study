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

let add (conn : Caqti_async.connection) a b =
  (* If you don't understand this line, refer to: study/hello-caqti-blocking/lib/repo/exec.ml *)
  let module Conn = (val conn : Caqti_async.CONNECTION) in
  Conn.find Q.add (a, b)
  [@@ocamlformat "disable"]

let mul (module Conn : Caqti_async.CONNECTION) a b = Conn.find Q.mul (a, b)

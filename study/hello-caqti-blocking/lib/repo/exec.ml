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

(** Caqti uses "first-class modules" to manage database connections.
  * Think of it like a simple value which you pass around and can't do anything with, until you "unpack"
  * it to access its API.
  *
  * In this example, we access the content of the [conn] first-class module by unpacking it into a normal module [Conn].
  * When working with a Caqti connection, consider following an "unpacking-where-used" approach.
  *
  * To learn more, see: https://dev.realworldocaml.org/first-class-modules.html
  *)
let add (conn : Caqti_blocking.connection) a b =
  let module Conn = (val conn : Caqti_blocking.CONNECTION) in
  Conn.find Q.add (a, b)
[@@ocamlformat "disable"]

(** As with [add], we "unpack" the first-class module. But this time "in place".
  * This is a syntax shortcut we should favor.
  *)
let mul (module Conn : Caqti_blocking.CONNECTION) a b =
  Conn.find Q.mul (a, b)
[@@ocamlformat "disable"]

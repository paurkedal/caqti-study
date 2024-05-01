(* SPDX-FileCopyrightText: 2024 Petter A. Urkedal <paurkedal@gmail.com>
 * SPDX-License-Identifier: MIT *)

(* This is an example of how to use Caqti directly in application code.
 * This way of defining typed wrappers around queries should also work for
 * code-generators. *)

 open Eio

 (* This is an example of a custom type, but it is experimental for now.  The
  * alternative is to use plain tuples, as the other queries below, and coverting
  * in client code. *)
 module Bike = struct
   type t = {
     frameno: string;
     owner: string;
     stolen: Ptime.t option;
   }
 end
 
 (* Query Strings
  * =============
  *
  * Queries are normally defined in advance.  This allows Caqti to emit
  * prepared queries which are reused throughout the lifetime of the
  * connection. *)
 
 module Q = struct
   open Caqti_request.Infix
   open Caqti_type.Std
 
   let bike =
     let open Bike in
     let intro frameno owner stolen = {frameno; owner; stolen} in
     product intro
       @@ proj string (fun bike -> bike.frameno)
       @@ proj string (fun bike -> bike.owner)
       @@ proj (option ptime) (fun bike -> bike.stolen)
       @@ proj_end
 
   let create_bikereg =
     unit ->. unit @@
     {eos|
       CREATE TEMPORARY TABLE bikereg (
         frameno text NOT NULL,
         owner text NOT NULL,
         stolen timestamp NULL
       )
     |eos}
 
   let reg_bike =
     t2 string string ->. unit @@
     "INSERT INTO bikereg (frameno, owner) VALUES (?, ?)"
 
   let report_stolen =
     string ->. unit @@
     "UPDATE bikereg SET stolen = current_timestamp WHERE frameno = ?"
 
   let select_stolen =
     unit ->* bike @@
     "SELECT * FROM bikereg WHERE NOT stolen IS NULL"
 
   let select_owner =
     string ->? string @@
     "SELECT owner FROM bikereg WHERE frameno = ?"
 end
 
 (* Wrappers around the Generic Execution Functions
  * ===============================================
  *
  * Here we combine the above queries with a suitable execution function, for
  * convenience and to enforce type safety.  We could have defined these in a
  * functor on CONNECTION and used the resulting module in place of Db. *)
 
 (* Db.exec runs a statement which must not return any rows.  Errors are
  * reported as exceptions. *)
 let create_bikereg (module Db : Caqti_eio.CONNECTION) =
   Db.exec Q.create_bikereg ()
 let reg_bike (module Db : Caqti_eio.CONNECTION) frameno owner =
   Db.exec Q.reg_bike (frameno, owner)
 let report_stolen (module Db : Caqti_eio.CONNECTION) frameno =
   Db.exec Q.report_stolen frameno
 
 (* Db.find runs a query which must return at most one row.  The result is a
  * option, since it's common to seach for entries which don't exist. *)
 let find_bike_owner frameno (module Db : Caqti_eio.CONNECTION) =
   Db.find_opt Q.select_owner frameno
 
 (* Db.iter_s iterates sequentially over the set of result rows of a query. *)
 let iter_s_stolen (module Db : Caqti_eio.CONNECTION) f =
   Db.iter_s Q.select_stolen f ()
 
 (* There is also a Db.iter_p for parallel processing, and Db.fold and
  * Db.fold_s for accumulating information from the result rows. *)
 
 
 (* Test Code
  * ========= *)
 
 let (>>=) r f = Result.bind r f
 
 let test stdout db =
   (* Examples of statement execution: Create and populate the register. *)
   create_bikereg db >>= fun () ->
   reg_bike db "BIKE-0000" "Arthur Dent" >>= fun () ->
   reg_bike db "BIKE-0001" "Ford Prefect" >>= fun () ->
   reg_bike db "BIKE-0002" "Zaphod Beeblebrox" >>= fun () ->
   reg_bike db "BIKE-0003" "Trillian" >>= fun () ->
   reg_bike db "BIKE-0004" "Marvin" >>= fun () ->
   report_stolen db "BIKE-0000" >>= fun () ->
   report_stolen db "BIKE-0004" >>= fun () ->
 
   (* Examples of single-row queries. *)
   let show_owner frameno =
     find_bike_owner frameno db >>= fun owner_opt ->
     Ok (match owner_opt with
        | Some owner -> Flow.copy_string (Printf.sprintf "%s is owned by %s.\n" frameno owner) stdout
        | None -> Flow.copy_string (Printf.sprintf "%s is not registered.\n" frameno) stdout
     )
    in
   show_owner "BIKE-0003" >>= fun () ->
   show_owner "BIKE-0042" >>= fun () ->
 
   (* An example multi-row query. *)
   Flow.copy_string "Stolen:" stdout;
   iter_s_stolen db
     (fun bike ->
       let stolen =
         match bike.Bike.stolen with Some x -> x | None -> assert false in
          Flow.copy_string (
            (Printf.sprintf "\t%s %s %s\n" bike.Bike.frameno)
            (Ptime.to_rfc3339 stolen)
            bike.Bike.owner
          ) stdout;
          Ok ()
     )
 
  let () = Eio_main.run @@ fun env ->
    let url =
      Printf.sprintf "postgresql://%s%s%s%s"
        (match Sys.getenv_opt "PGUSER" with Some user -> user^"@" | None -> "")
        (match Sys.getenv_opt "PGHOST" with Some host -> host | None -> "")
        (match Sys.getenv_opt "PGPORT" with Some port -> ":"^port | None -> "")
        (match Sys.getenv_opt "PGDATABASE" with Some database -> "/"^database | None -> "")
      |> Uri.of_string
    in
    (* Note: Caqti_eio_unix is required for the postgresql driver, while the pure ocaml pgx can be used with Caqti_eio*)
    Caqti_eio_unix.with_connection ~stdenv:(env :> Caqti_eio.stdenv) url (test env#stdout)
    |> Caqti_eio.or_fail
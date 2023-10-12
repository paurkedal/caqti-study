(* If we can get access to some env vars, we construct a special URI to use our local DB.
   Otherwise, we return a default URI. We would then use our system DB.

   What is this `let*` syntax? In short, it allows to minimize the boilerplate associated to extracting **optional** values.
   Once we reach the bottom, we know all the prior function calls have successfully ran. Otherwise, the function short-circuits and returns `None`.
*)
let get_uri () =
  let env_vars =
    let ( let* ) = Option.bind in
    let* pg_host = Sys.getenv_opt "PGHOST" in
    let* pg_port = Sys.getenv_opt "PGPORT" in
    let* pg_database = Sys.getenv_opt "PGDATABASE" in
    Some (pg_host, pg_port, pg_database)
  in
  match env_vars with
  | Some (pg_host, pg_port, pg_database) ->
      Printf.sprintf "postgresql://%s:%s/%s" pg_host pg_port pg_database
  | None -> "postgresql://"

let connect () =
  let uri = get_uri () in
  Caqti_lwt_unix.connect (Uri.of_string uri)

(** For `utop` interactions interactions. See `README.md`.
 *)
let connect_exn () =
  let conn_promise = connect () in
  match Lwt_main.run conn_promise with
  | Error err ->
      let msg =
        Printf.sprintf "Abort! We could not get a connection. (err=%s)\n"
          (Caqti_error.show err)
      in
      failwith msg
  | Ok module_ -> module_

module Q = struct
  open Caqti_request.Infix

  let create_author_tbl =
    Caqti_type.(unit ->. unit)
      {|
         CREATE TABLE author
           ( id          INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY
           , first_name  TEXT NOT NULL CHECK (LENGTH(first_name) < 255)
           , middle_name TEXT     NULL CHECK (LENGTH(first_name) < 255)
           , last_name   TEXT NOT NULL CHECK (LENGTH(last_name)  < 255)
           )
      |}

  let create_book_tbl =
    Caqti_type.(unit ->. unit)
      {|
         CREATE TABLE book
           ( id               INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY
           , title            TEXT    NOT NULL UNIQUE CHECK (LENGTH(title) < 255)
           , back_cover_descr TEXT        NULL
           )
      |}

  let create_bibliography_tbl =
    Caqti_type.(unit ->. unit)
      {|
         CREATE TABLE bibliography
           ( id        INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY
           , book_id   INTEGER NOT NULL REFERENCES book(id)
           , author_id INTEGER NOT NULL REFERENCES author(id)
           )
      |}
end

let create_tables (module Conn : Caqti_lwt.CONNECTION) =
  let open Lwt_result.Syntax in
  let* () = Conn.start () in
  let* () = Conn.exec Q.create_author_tbl () in
  let* () = Conn.exec Q.create_book_tbl () in
  let* () = Conn.exec Q.create_bibliography_tbl () in
  let* () = Conn.commit () in
  Lwt.return_ok () (* Optional line. For clarity and symetry *)

let transact (module Conn : Caqti_lwt.CONNECTION) fn =
  let open Lwt_result.Syntax in
  let* () = Conn.start () in
  let* () = fn () in
  let* () = Conn.commit () in
  Lwt.return_ok ()

(*
     $ PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune utop
     utop # open Repo;;
     utop # let conn = Init.connect_exn ();;
     utop # Init.create_tables conn;;
     utop # Init.seed conn;;
     utop # Bibliography.ls conn ();;
*)

let seed conn =
  (* NOTE: using a `RETURNING id` clause requires sqlite >= v3.35, ok on Ubuntu 22.04, not ok on Ubuntu 20.04 *)
  let add_data () =
    let add_author = Author.insert' conn in
    let add_book = Book.insert' conn in
    let add_bibli = Bibliography.insert conn in
    let open Lwt_result.Syntax in
    (*
     * John Whitington
     *)
    let* john_whitigton =
      add_author
        { first_name = "John"; middle_name = None; last_name = "Whitington" }
    in
    let* ocaml_ftvb = add_book { title = "OCaml from the Very Beginning" } in
    let* more_ocaml = add_book { title = "More OCaml" } in
    let* () = add_bibli { author_id = john_whitigton; book_id = ocaml_ftvb } in
    let* () = add_bibli { author_id = john_whitigton; book_id = more_ocaml } in

    (*
     * Graham Hutton
     *)
    let* graham_hutton =
      add_author
        { first_name = "Graham"; middle_name = None; last_name = "Hutton" }
    in
    let* prog_with_haskell = add_book { title = "Programming in Haskell" } in
    let* () =
      add_bibli { author_id = graham_hutton; book_id = prog_with_haskell }
    in

    (*
     * Anil Madhavapeddy and Yaron Minsky
     *)
    let* anil_madhavapeddy =
      add_author
        { first_name = "Anil"; middle_name = None; last_name = "Madhavapeddy" }
    in
    let* yaron_minsky =
      add_author
        { first_name = "Yaron"; middle_name = None; last_name = "Minsky" }
    in
    let* rwo = add_book { title = "Real World OCaml" } in
    let* () = add_bibli { author_id = anil_madhavapeddy; book_id = rwo } in
    let* () = add_bibli { author_id = yaron_minsky; book_id = rwo } in

    Lwt.return_ok ()
  in
  transact conn add_data

let add_author conn first_name last_name : (unit, 'error) result Lwt.t =
  Author.insert conn { first_name; middle_name = None; last_name }

let seed_alt conn : (unit, 'error) result Lwt.t =
  let ( let* ) = Lwt_result.bind in
  let* () = add_author conn "John" "Doe" in
  let* () = add_author conn "Jane" "Doe" in
  let* () = add_author conn "Robert" "Doe" in
  Lwt.return_ok ()

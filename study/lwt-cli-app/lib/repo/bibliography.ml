module Row = struct
  type t = {
    book_id : int;
    title : string;
    first_name : string;
    middle_name : string option;
    last_name : string;
  }
end

module Q = struct
  open Caqti_request.Infix

  (*
    Caqti infix operators

    ->! decodes a single row
    ->? decodes zero or one row
    ->* decodes many rows
    ->. expects no row
  *)

  let insert =
    Caqti_type.(t2 int int ->. unit)
      {|
       INSERT INTO bibliography (author_id, book_id) VALUES (?, ?)
      |}

  let ls =
    Caqti_type.(unit ->* t5 int string string (option string) string)
      {|
       SELECT x.id
            , b.title
            , a.first_name
            , a.middle_name
            , a.last_name
       FROM bibliography AS x

       INNER JOIN author AS a
               ON a.id = x.author_id

       INNER JOIN book AS b
               ON b.id = x.book_id
      |}

  let ls' =
    Caqti_type.(unit ->* t2 int string)
      {|
       SELECT x.id
            , b.title
       FROM bibliography AS x

       INNER JOIN author AS a
               ON a.id = x.author_id

       INNER JOIN book AS b
               ON b.id = x.book_id
      |}
end

type bibliography = { author_id : int; book_id : int }

let insert (module Conn : Caqti_lwt.CONNECTION) (b : bibliography) =
  Conn.exec Q.insert (b.author_id, b.book_id)

(*
   $ PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune utop
   utop # open Repo;;
   utop # let conn = Init.connect_exn ();;
   utop # Bibliography.ls conn ();;
*)
let ls (module Conn : Caqti_lwt.CONNECTION) = Conn.collect_list Q.ls ()
let ls' (module Conn : Caqti_lwt.CONNECTION) = Conn.collect_list Q.ls' ()

let drop_all_tables (module Conn : Caqti_lwt.CONNECTION) =
  let open Caqti_request.Infix in
  let run str = Conn.exec (Caqti_type.(unit ->. unit) str) () in

  let open Lwt_result.Syntax in
  let* () = Conn.start () in
  let* () = run "DROP TABLE IF EXISTS bibliography" in
  let* () = run "DROP TABLE IF EXISTS book" in
  let* () = run "DROP TABLE IF EXISTS author" in
  let* () = Conn.commit () in
  Lwt.return_ok () (* Optional line. For clarity and symmetry *)

let fresh_db () : ((module Caqti_lwt.CONNECTION), 'err) result Lwt.t =
  let setup : ((module Caqti_lwt.CONNECTION), 'error) result Lwt.t =
    let open Lwt_result.Syntax in
    let* conn = Repo.Init.connect () in
    let* () = drop_all_tables conn in
    let* () = Repo.Init.create_tables conn in
    Lwt.return_ok conn
  in
  setup

let fresh_db () : ((module Caqti_lwt.CONNECTION), 'err) result Lwt.t =
  let setup : ((module Caqti_lwt.CONNECTION), 'error) result Lwt.t =
    let open Lwt_result.Syntax in
    let* conn = Repo.Init.connect () in
    let* () = Repo.Init.teardown conn in
    let* () = Repo.Init.setup conn in
    Lwt.return_ok conn
  in
  setup

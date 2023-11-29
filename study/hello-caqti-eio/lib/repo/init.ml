(*
  If we can get access to some env vars, we construct a special URI to use our local DB.
  Otherwise, we return a default URI. We would then use our system DB.
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

let with_conn f ~stdenv =
  let uri = Uri.of_string @@ get_uri () in
  Caqti_eio_unix.with_connection uri ~stdenv f

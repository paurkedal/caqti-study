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
      (* Equivalent to: PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 psql *)
      Printf.sprintf "postgresql://%s:%s/%s" pg_host pg_port pg_database
  | None -> "postgresql://"

let connect () =
  let uri = get_uri () in
  Caqti_blocking.connect (Uri.of_string uri)

(** For `utop` interactions interactions. See `README.md`.
 *)
let connect_exn () =
  match connect () with
  | Error err ->
      let msg =
        Printf.sprintf "Abort! We could not get a connection. (err=%s)\n"
          (Caqti_error.show err)
      in
      failwith msg
  | Ok module_ -> module_

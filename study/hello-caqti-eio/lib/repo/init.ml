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

let new_stdenv env : Caqti_eio.stdenv =
  object
    method clock = Eio.Stdenv.clock env
    method mono_clock = Eio.Stdenv.mono_clock env
    method net = Eio.Stdenv.net env
  end

(*
  In eio, we need to send a "switch" to the callee, for it to do among other
  things resources cleanup.

  Thusly, we can't hold on to a connection as we did in the previous projects.
  For when the switch goes out of scope, the connection becomes stale.
  So we will instead pass-in the function [f] to do work, callback-style.
*)
let with_conn f =
  let ( let* ) = Result.bind in
  let connect =
    let uri = get_uri () in
    Caqti_eio_unix.connect (Uri.of_string uri)
  in
  Eio_main.run @@ fun env ->
  Eio.Switch.run @@ fun sw ->
  let* conn = connect ~sw ~stdenv:(new_stdenv env) in
  f conn

(*
  It turns out that this callback style is already generally supported by Caqti's API.
  We could apply this "with_connection" pattern to any connection ([lwt], [async], etc.)
*)
let with_conn' f =
  let uri = get_uri () in
  Eio_main.run @@ fun env ->
  Caqti_eio_unix.with_connection (Uri.of_string uri) ~stdenv:(new_stdenv env) f

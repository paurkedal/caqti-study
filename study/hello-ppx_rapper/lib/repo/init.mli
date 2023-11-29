val connect :
  unit -> (Caqti_lwt.connection, [> Caqti_error.load_or_connect ]) result Lwt.t

val connect_exn : unit -> Caqti_lwt.connection
(** For `utop` interactions interactions only. See `README.md`.
  *)

val connect :
  unit ->
  ((module Caqti_lwt.CONNECTION), [> Caqti_error.load_or_connect ]) result Lwt.t

val connect_exn : unit -> (module Caqti_lwt.CONNECTION)

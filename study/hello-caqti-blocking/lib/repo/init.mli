val connect :
  unit ->
  ((module Caqti_blocking.CONNECTION), [> Caqti_error.load_or_connect ]) result

val connect_exn : unit -> (module Caqti_blocking.CONNECTION)

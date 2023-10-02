val connect :
  unit ->
  ( (module Caqti_async.CONNECTION),
    [> Caqti_error.load_or_connect ] )
  Async.Deferred.Result.t

val connect_exn : unit -> (module Caqti_async.CONNECTION)

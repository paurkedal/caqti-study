(** This function transforms a promised Caqti error to a string, to make defining test expectations easier.
 *)
let str_error prom = Lwt.map (Result.map_error Caqti_error.show) prom

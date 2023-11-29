val get_uri : unit -> string

val with_conn :
  (Caqti_eio.connection ->
  ('a, ([> Caqti_error.load_or_connect ] as 'e)) result) ->
  stdenv:Caqti_eio.stdenv ->
  ('a, 'e) result
(** [with_conn f ~stdenv] runs [f] with the given [stdenv].

    Examples:
    {[
      with_conn ~stdenv (fun conn -> Repo.Exec.add 1 2 conn)
      with_conn ~stdenv (Repo.Exec.add 1 2)
    ]}

*)

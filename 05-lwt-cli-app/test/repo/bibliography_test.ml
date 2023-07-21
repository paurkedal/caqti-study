module Bibliography = Repo.Bibliography

let str_error = Utils.str_error

let%test_unit "seed the database, then read many rows" =
  let ( => ) =
    [%test_eq:
      ( (Base.int * Base.string * Base.string * Base.string) Base.list,
        Base.string )
      Base.Result.t]
  in

  let prom =
    let open Lwt_result.Syntax in
    let* conn = Setup.fresh_db () in
    let* () = Repo.Init.seed conn in
    let+ found = Bibliography.ls conn in
    (* Example showing how to go beyond tup4 (there is no tup5) *)
    List.map
      (fun (id, (title, (first_name, (_middle_name, last_name)))) ->
        (id, title, first_name, last_name))
      found
  in
  Lwt_main.run (str_error prom)
  => Ok
       [
         (1, "OCaml from the Very Beginning", "John", "Whitington");
         (2, "More OCaml", "John", "Whitington");
         (3, "Programming in Haskell", "Graham", "Hutton");
         (4, "Real World OCaml", "Anil", "Madhavapeddy");
         (5, "Real World OCaml", "Yaron", "Minsky");
       ]

let%test_unit "seed the database, then read many rows (alt, simple)" =
  let ( => ) =
    [%test_eq: ((Base.int * Base.string) Base.list, Base.string) Base.Result.t]
  in
  let prom =
    let open Lwt_result.Syntax in
    let* conn = Setup.fresh_db () in
    let* () = Repo.Init.seed_alt conn in
    Repo.Author.ls' conn
  in

  Lwt_main.run (str_error prom)
  => Ok [ (1, "John"); (2, "Jane"); (3, "Robert") ]

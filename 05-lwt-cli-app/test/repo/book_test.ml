module Book = Repo.Book

let str_error = Utils.str_error

let%test_unit "count returns 0, when there are no rows" =
  let ( => ) = [%test_eq: (Base.int, Base.string) Base.Result.t] in
  let prom =
    let open Lwt_result.Syntax in
    let* conn = Setup.fresh_db () in
    Book.count conn
  in
  Lwt_main.run (str_error prom) => Ok 0

let%test_unit "count returns 1, after inserting OFTVB" =
  let ( => ) = [%test_eq: (Base.int, Base.string) Base.Result.t] in
  let prom =
    let open Lwt_result.Syntax in
    let* conn = Setup.fresh_db () in
    let* () = Book.insert conn { title = "OCaml from the Very Beginning" } in
    Book.count conn
  in
  Lwt_main.run (str_error prom) => Ok 1

let%test_unit "find_by_id: not found" =
  let ( => ) =
    [%test_eq:
      ((Base.int * Base.string) Base.option, Base.string) Base.Result.t]
  in
  let prom =
    let open Lwt_result.Syntax in
    let* conn = Setup.fresh_db () in
    Book.find_by_id conn 1
  in
  Lwt_main.run (str_error prom) => Ok None

let%test_unit "find_by_id: found" =
  let ( => ) =
    [%test_eq:
      ((Base.int * Base.string) Base.option, Base.string) Base.Result.t]
  in
  let prom =
    let open Lwt_result.Syntax in
    let* conn = Setup.fresh_db () in
    let* () = Book.insert conn { title = "Real World OCaml" } in
    Book.find_by_id conn 1
  in
  Lwt_main.run (str_error prom) => Ok (Some (1, "Real World OCaml"))

let%test_unit "read many" =
  let ( => ) =
    [%test_eq: ((Base.int * Base.string) Base.list, Base.string) Base.Result.t]
  in

  let prom =
    let open Lwt_result.Syntax in
    let* conn = Setup.fresh_db () in
    let* () = Book.insert conn { title = "More OCaml" } in
    let* () = Book.insert conn { title = "Real World OCaml" } in

    Book.ls conn
  in
  Lwt_main.run (str_error prom)
  => Ok [ (1, "More OCaml"); (2, "Real World OCaml") ]

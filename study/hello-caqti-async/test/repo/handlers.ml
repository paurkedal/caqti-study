open Async

[@@@warning "-32"]

let promise =
  let open Deferred.Result.Let_syntax in
  let%bind number = Deferred.return (Ok 1) in
  Deferred.return (Ok (number * 2))

let promise =
  let open Deferred.Result.Let_syntax in
  let%map number = Deferred.return (Ok 1) in
  number * 2

let promise_one = Deferred.return (Ok 1)

let promise =
  Deferred.map promise_one ~f:(fun result ->
      Core.Result.map ~f:(fun number -> number * 2) result)

let promise =
  Deferred.bind promise_one ~f:(fun result ->
    result
    |> Core.Result.map ~f:(fun number -> number * 2)
    |> Deferred.return
  )
[@@ocamlformat "disable"]

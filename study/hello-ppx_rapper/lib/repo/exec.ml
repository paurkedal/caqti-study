(* With ppx_rapper, we use this syntax:
 * - %type_name{parameter_name} to declare input parameters to our function
 *   - they get translated to label params ~parameter_name
 * - @int{sql_value} to declare output values to our function
 *
 * This has an effect on the input types and output types of our function (via the ppx code-gen).
 * NOTE: the connection parameter automatically comes last.
 *)
let add =
  [%rapper
    get_one
      {sql|
          SELECT @int{x.result}
          FROM (
            SELECT %int{a} + %int{b} AS result
          )x
      |sql}]

(* Let's say we wanted to keep an API identical to the one we saw in "hello-caqti-lwt".
 * Nothing's stopping us from slightly arranging things to conform to an API of our choosing.
 *)
let mul conn a b =
  [%rapper
    get_one
      {sql|
          SELECT @int{x.result}
          FROM (
            SELECT %int{a} * %int{b} AS result
          )x
      |sql}]
    ~a ~b conn

let resolve_ok_exn promise =
  match Lwt_main.run promise with
  | Error _ -> failwith "Oops, I encountered an error!"
  | Ok n -> n

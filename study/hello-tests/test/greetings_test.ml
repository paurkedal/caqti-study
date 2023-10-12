(*

  Run with one of:

    - dune runtest --watch
    - dune build @all @runtest --watch
 *)

(*
 * ppx_inline_test examples
 *)

(* A named example *)
let%test "1+1=2" = 1 + 1 = 2

(* Naming the test is optional *)
let%test _ = 1 + 2 = 3

(* We test equality, so the order does not matter *)
let%test _ = 3 = 1 + 2

(*
 * ppx_assert examples. It requires the `base` library but we won't include it into our global namespace.
 *)

(* A named example *)
let%test_unit "1+1=2" = [%test_eq: Base.int] (1 + 1) 2

(* Naming the test is also optional *)
let%test_unit _ = [%test_eq: Base.int] (1 + 2) 3

(* Again, we test equality, so the order does not matter *)
let%test_unit _ = [%test_eq: Base.int] 3 (1 + 2)

(* To make things slightly easier to read, We will introduce this custom operator *)
let%test_unit _ =
  let ( => ) = [%test_eq: Base.int] in
  1 + 1 => 2

(* We can then test multiple conditions in a pretty readable fashion *)
let%test_unit _ =
  let ( => ) = [%test_eq: Base.int] in
  1 + 1 => 2;
  1 + 2 => 3;
  1 + 3 => 4

(* Finally, we want to test our library code! *)
let%test _ = "Hello, World!" = My_lib.Greetings.world

let%test_unit _ =
  let ( => ) = [%test_eq: Base.string] in
  My_lib.Greetings.world => "Hello, World!"

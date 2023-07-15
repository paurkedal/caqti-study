(*
  Run with:

    dune exec ./bin/main.exe [--watch]
*)
() =
  let str = My_lib.Greetings.world in
  print_endline str
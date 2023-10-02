(*
  Run with:
    PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune exec ./bin/cli_app.exe

  NOTE:
    Run the "simple" app first to seed the database
*)

open Printf

let help =
  {|
  This REPL accepts commands of the following form:

  - { ACTION }
  - { RESOURCE } { ACTION }

  Examples:

    - help
    - quit
    - author ls
    - author find 1
    - author delete 1 : TODO
    - author insert : TODO
    - book ls
    - book find 1
    - book other TODO

  NOTE:

    Once you enter a "resource" command (e.g. `author ls`), your REPL state changes, like this:

      author> CURSOR_HERE

    In this mode the "resource" prefix is already set. So you just enter "ls", "find 1", etc.

    Type "main" (or Ctrl+D) to drop back to the main REPL.

  |}

let get_line () = In_channel.input_line In_channel.stdin

let print_header str =
  print_string str;
  print_string "> ";
  flush Out_channel.stdout

let rec read_attribute name validate =
  let () = printf "%s: %!" name in
  let got = read_line () in
  match validate got with
  | Error x ->
      (* Ideally, we would be able to keep any prior user input, but this requires `readline`
         support which will make the example more complicated than need be. *)
      printf "Validation error: %s\nStart again (sorry!)\n" x;
      read_attribute name validate
  | Ok v -> v

(** It is assumed these command won't fail at runtime, given the fact they've been tested.
    Regardless, we probably don't want to print a specific error message in this context *)
let run_promise p f =
  match Lwt_main.run p with
  | Error _ -> print_endline "Sorry, something went wrong!"
  | Ok x -> f x

module Validate = struct
  let len_gte n input =
    if String.length input >= n then
      Ok input
    else
      Error "Length must be greater than or equal to 3"
  [@@ocamlformat "disable"]
end

module Author_REPL = struct
  module Author = Repo.Author

  type author = Author.author

  let print_author (id, first_name, last_name) =
    printf "%d) %s %s\n%!" id first_name last_name

  let print_author_opt = function
    | None -> print_endline "Author not found!"
    | Some x -> print_author x

  let get_args () =
    print_header "author";
    match get_line () with
    | None -> []
    | Some str -> String.split_on_char ' ' str

  let read_author () : author =
    let first_name = read_attribute "First name" (Validate.len_gte 3) in
    let last_name = read_attribute "Last name" (Validate.len_gte 3) in
    { first_name; middle_name = None; last_name }

  let rec run conn args =
    let again = run conn in
    match args with
    | [] | "main" :: [] ->
        (* Ctrl+D or typed "main" *)
        print_newline ()
    | "ls" :: [] ->
        run_promise (Author.ls conn) @@ List.iter print_author;
        again (get_args ())
    | "insert" :: [] ->
        let author = read_author () in
        run_promise (Author.insert' conn author) (fun id ->
            printf "Insert OK (id=%d)\n" id);
        again (get_args ())
    | [ "find"; id ] ->
        (match int_of_string_opt id with
        | Some id -> run_promise (Author.find_by_id conn id) print_author_opt
        | None -> print_endline "Invalid ID. Usage: find NUMBER");
        again (get_args ())
    | _ ->
        print_endline "Unknown author command or sub-command!";
        again (get_args ())
end

module Book_REPL = struct
  module Book = Repo.Book

  let print_book (id, first_name) = printf "%d) %s\n%!" id first_name

  let print_book_opt = function
    | None -> print_endline "Book not found!"
    | Some x -> print_book x

  let get_args () =
    print_header "book";
    match get_line () with
    | None -> []
    | Some str -> String.split_on_char ' ' str

  let rec run conn args =
    let again = run conn in
    match args with
    | [] | "main" :: [] ->
        (* Ctrl+D or typed "main" *)
        print_newline ()
    | "ls" :: [] ->
        run_promise (Book.ls conn) @@ List.iter print_book;
        again (get_args ())
    | "insert" :: [] ->
        print_endline "will start book insert mode";
        again (get_args ())
    | [ "find"; id ] ->
        (match int_of_string_opt id with
        | Some id -> run_promise (Book.find_by_id conn id) print_book_opt
        | None -> print_endline "Invalid ID. Usage: find NUMBER");
        again (get_args ())
    | _ ->
        print_endline "Unknown book command or sub-command!";
        again (get_args ())
end

module Main_REPL = struct
  let rec run conn =
    let eval_print_loop = function
      | "quit" :: [] -> print_endline "Bye bye!"
      | "help" :: [] ->
          print_endline help;
          run conn
      | "author" :: args ->
          Author_REPL.run conn args;
          run conn
      | "book" :: args ->
          Book_REPL.run conn args;
          run conn
      | _ ->
          print_endline "Unknown command!";
          run conn
    in
    print_header "main";
    match get_line () with
    | Some line -> eval_print_loop (String.split_on_char ' ' line)
    | None ->
        (* Ctrl+D *)
        print_newline ();
        print_endline "See you next time!";
        ()
end

let () =
  match Lwt_main.run (Repo.Init.connect ()) with
  | Error err ->
      print_endline "Can't start the app! I could not connect to the database!!";
      prerr_endline (Caqti_error.show err)
  | Ok conn ->
      print_endline {|Welcome to our CLI app! (type "help" to learn more)|};
      Main_REPL.run conn

# Hello, ppx_rapper!

Let's take a look at [ppx_rapper](https://github.com/roddyyaga/ppx_rapper)!

We have already seen what PPXs are, so we are good to go!

Have a look at the [Exec](lib/repo/exec.ml) module. We converted queries from the [hello-caqti-lwt](../hello-caqti-lwt) project, to a much shorter syntax. Although, we have to adjust the SQL slightly in order to satisfy ppx_rapper's requirements.

Also take a look [Fake_users](lib/repo/fake_users.ml) module for other types of usage, and as always the tests.

**NOTE**

At the time of writing, it's necessary to run this command in order to have a version of ppx_rapper compatible with the latest Caqti version.

```
opam pin add git+https://github.com/roddyyaga/ppx_rapper#2222edbbe68db7ba1ab0c7a2688c227ea5c0f230
```

See [ppx_rapper PR#35](https://github.com/roddyyaga/ppx_rapper/pull/35) for more details


## Test via the REPL

As in the previous projects, let's play with our REPL for a bit :)

```
$ PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 dune utop
```

Let's initialize our connection:
```ocaml
# open Repo;;
# let conn = Init.connect_exn ();;
val conn : Caqti_lwt.connection = <module>
```

We have a new API! We use labeled arguments now, and the connection comes last. That API comes from the ppx_rapper code generation.
```ocaml
# Repo.Exec.resolve_ok_exn @@ Exec.add ~a:1 ~b:2 conn;;
- : int = 3
```

We can still keep our old API if it were for whatever reason necessary.
```ocaml
# Repo.Exec.resolve_ok_exn @@ Exec.mul conn 3 4 ;;
- : int = 12
```

We've also got a list of fake users to play with
```ocaml
# open Repo.Fake_users
# Repo.Exec.resolve_ok_exn @@ Repo.Fake_users.fake_users () conn |> List.map (fun user -> user.email);;
- : string list =
["user1@example.com"; "user2@example.com"; "user3@example.com";
 "user4@example.com"; "user5@example.com"]
```

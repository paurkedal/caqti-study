let forty_two = [%rapper get_one {sql|SELECT @int{42}+%int{offset}|sql}]

let series =
  [%rapper
    get_many
      {sql|
         SELECT @int{generate_series} FROM generate_series(1, 5)
      |sql}]

(* We use "shift" as a parameter rather than "offset" since it clashes with the SQL keyword *)
let series' =
  [%rapper
    get_many
      {sql|
        SELECT @int{x.num} + %int{shift} FROM (
          SELECT * FROM generate_series(1, 5) AS num
        )x
      |sql}]

type user = { user_id : int; email : string; is_account_active : bool }

(* [record_out] maps to our user above, thanks to type inference! *)
let fake_users =
  [%rapper
    get_many
      {sql|
        SELECT @int{x.user_id}
             , @string{x.email}
             , @bool{x.is_account_active}
        FROM (
          SELECT generate_series AS user_id
               , 'user' || generate_series || '@example.com' AS email
               , random() < 0.5 AS is_account_active
          FROM generate_series(1, 5)
        )x
      |sql}
      record_out]

open Tokenbot
open Cooldown

let%test "token returns coffee emoji" =
  let cooldown = Item.(Token "☕️", Seconds 1) in
  Cooldown.token cooldown = Token "☕️"

let%test "token returns pizza emoji" =
  let cooldown = Cooldown.make Item.(Token "🍕") (Seconds 100) in
  Cooldown.token cooldown = Token "🍕"

let%test "token returns duration of 100 seconds" =
  let cooldown = Cooldown.make Item.(Token "🍕") (Seconds 100) in
  Cooldown.duration cooldown = 100

let%test "token returns duration of 1 Minute" =
  let cooldown = Cooldown.make Item.(Token "🍕") (Minutes 1) in
  Cooldown.duration cooldown = 60

let%test "token with 10 seconds returns 10 second duration" =
  let cooldown = Cooldown.make Item.(Token "🍕") (Seconds 10) in
  Cooldown.duration cooldown = 10

let%test "token with 2 minutes returns 120 second duration" =
  let cooldown = Cooldown.make Item.(Token "🍕") (Minutes 2) in
  Cooldown.duration cooldown = 120

let%test "token with 3 hours returns 10800 second duration" =
  let cooldown = Cooldown.make Item.(Token "🍕") (Hours 3) in
  Cooldown.duration cooldown = 10800

let%test "stack inserts coffee with one minute duration" =
  let items = [] in
  let item = Cooldown.make Item.(Token "☕️") (Minutes 1) in
  let expected = [ Item.(Token "☕️", 60) ] in
  let actual = Cooldown.stack items item in
  actual = expected

let%test "stack inserts coffee with one hour duration" =
  let items = [] in
  let item = Cooldown.make Item.(Token "☕️") (Hours 1) in
  let expected = [ Item.(Token "☕️", 3600) ] in
  let actual = Cooldown.stack items item in
  actual = expected

let%test "stack inserts on coffee on a pizza" =
  let items = [ Cooldown.make Item.(Token "🍕") (Minutes 1) ] in
  let item = Cooldown.make Item.(Token "☕️") (Hours 1) in
  let expected = item :: items in
  let actual = Cooldown.stack items item in
  actual = expected

let%test "stack increases coffee duration by 1 minute" =
  let items =
    [
      Cooldown.make Item.(Token "☕️") (Minutes 1);
      Cooldown.make Item.(Token "🍕") (Hours 1);
      Cooldown.make Item.(Token "🔥") (Seconds 45);
    ]
  in
  let item = Cooldown.make Item.(Token "☕️") (Minutes 1) in
  Cooldown.stack items item
  = [
      Cooldown.make Item.(Token "☕️") (Minutes 2);
      Cooldown.make Item.(Token "🍕") (Hours 1);
      Cooldown.make Item.(Token "🔥") (Seconds 45);
    ]

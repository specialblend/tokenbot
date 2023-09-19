open Tokenbot
open Item

let print_item Item.(Token emoji, qty) =
  print_endline (Format.sprintf "%sx%d" emoji qty)

let%expect_test "example snapshot test" =
  (* run some code *)
  print_endline "foo";
  [%expect {| foo |}]

let%test "example assertion test" = true

let%test "token returns coffee emoji" =
  let item = (Token "☕️", 1) in
  let expected = Token "☕️" in
  let actual = Item.token item in
  actual = expected

let%test "token returns pizza emoji" =
  let item = (Token "🍕", 100) in
  let expected = Token "🍕" in
  let actual = Item.token item in
  actual = expected

let%test "qty returns 1" =
  let item = (Token "☕️", 1) in
  let expected = 1 in
  let actual = Item.qty item in
  actual = expected

let%test "qty returns 12" =
  let item = (Token "☕️", 12) in
  let expected = 12 in
  let actual = Item.qty item in
  actual = expected

let%test "token returns coffee emoji and qty returns 3" =
  let item = (Token "☕️", 3) in
  let tok = Item.token item
  and qty = Item.qty item in
  tok = Token "☕️" && qty = 3

let%test "make returns expected tuple" =
  let item = Item.make (Token "☕️") 3 in
  let expected = (Token "☕️", 3) in
  item = expected

let%test "map_qty returns same qty of 3" =
  let item = Item.make (Token "☕️") 3 in
  let received = Item.map_qty (fun qty -> qty) item in
  received = item

let%test "map_qty returns same qty of 12" =
  let item = Item.make (Token "☕️") 12 in
  let received = Item.map_qty (fun qty -> qty) item in
  received = item

let%test "map_qty increases qty by 3" =
  let q = 12 in
  let item = Item.make (Token "☕️") q in
  let _, received = Item.map_qty (( + ) 3) item in
  received = q + 3

let%test "stack inserts 3 coffee" =
  let items = [] in
  let item = Item.make (Token "☕️") 3 in
  let expected = [ item ] in
  let actual = Item.stack items item in
  actual = expected

let%test "stack inserts 2 pizza" =
  let items = [] in
  let item = Item.make (Token "🍕") 2 in
  let expected = [ item ] in
  let actual = Item.stack items item in
  actual = expected

let%test "stack inserts 3 coffee" =
  let items = [ Item.make (Token "🍕") 2 ] in
  let item = Item.make (Token "☕️") 3 in
  let expected = item :: items in
  let actual = Item.stack items item in
  actual = expected

let%expect_test "stack increases coffee to 10" =
  let items = [ Item.make (Token "☕️") 3; Item.make (Token "🍕") 2 ] in
  let item = Item.make (Token "☕️") 7 in
  let actual = Item.stack items item in

  List.iter (fun item -> print_item item) actual;

  [%expect {|
    ☕️x10
    🍕x2 |}]

let%test "stack increases coffee to 12" =
  let items = [ Item.make (Token "☕️") 5; Item.make (Token "🍕") 2 ] in
  let item = Item.make (Token "☕️") 7 in
  let actual = Item.stack items item in
  actual = [ Item.make (Token "☕️") 12; Item.make (Token "🍕") 2 ]

let%test "stack increases coffee to 10 ..." =
  let items = [ Item.make (Token "☕️") 3; Item.make (Token "🍕") 7 ] in
  let item = Item.make (Token "☕️") 7 in
  let actual = Item.stack items item in
  actual = [ Item.make (Token "☕️") 10; Item.make (Token "🍕") 7 ]

let%expect_test "stack increases coffee to 10 ..." =
  let items =
    [
      Item.make (Token "☕️") 3;
      Item.make (Token "🍕") 7;
      Item.make (Token "☕️") 2;
      Item.make (Token "☕️") 1;
    ]
  in
  let item = Item.make (Token "☕️") 7 in
  let actual = Item.stack items item in

  List.iter print_item actual;

  [%expect {|
    ☕️x10
    🍕x7
    ☕️x2
    ☕️x1 |}]

let%expect_test "stack increases coffee to 10 ..." =
  let items =
    [
      Item.make (Token "☕️") 3; Item.make (Token "☕️") 2; Item.make (Token "☕️") 1;
    ]
  in
  let item = Item.make (Token "☕️") 7 in
  let actual = Item.stack items item in

  List.iter print_item actual;

  [%expect {|
  ☕️x10
  ☕️x2
  ☕️x1 |}]

open Tokenbot

module Roll_test = struct
  let%expect_test _ =
    let qty = 1 in
    let dice _ = 1 in
    let tokens = Token.roll_many Token.luck_bonus ~qty ~dice in
    List.iter print_string tokens;
    [%expect {| 🌮 |}]
end

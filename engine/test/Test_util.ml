open Tokenbot

let print_player player =
  print_endline (Player.show player);
  print_endline "---"

let print_deposit deposit =
  print_endline (Thanks.Deposit.show deposit);
  print_endline "---"

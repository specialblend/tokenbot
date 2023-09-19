open Tokenbot

let%test "it gives 1 taco without comment or cooldown" =
  let player1 = Player.make ~name:"player1" "player1" in
  let deposit = Deposit.give player1 "🌮" in

  Deposit.token deposit = Token "🌮"
  && Deposit.player_id deposit = player1.id
  && Deposit.cooldown deposit = None
  && Deposit.about deposit = None

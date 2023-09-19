open Tokenbot

let%test "it gives 1 taco without comment or cooldown" =
  let player1 = Player.make ~name:"player1" "player1" in
  let deposit = Deposit.give player1 "🌮" in

  Deposit.token deposit = Token "🌮"
  && Deposit.qty deposit = 1
  && Deposit.player_id deposit = player1.id
  && Deposit.about deposit = None
  && Deposit.cooldown deposit = None

let%test "it gives 3 coffee without comment or cooldown" =
  let player1 = Player.make ~name:"player1" "player1" in
  let deposit = Deposit.give player1 ~qty:3 "☕️" in

  Deposit.token deposit = Token "☕️"
  && Deposit.qty deposit = 3
  && Deposit.player_id deposit = player1.id
  && Deposit.about deposit = None
  && Deposit.cooldown deposit = None

let%test "it gives 1 beer with expected comment and no cooldown" =
  let player1 = Player.make ~name:"player1" "player1" in
  let deposit = Deposit.give player1 "🍻" ~about:"TGIF" in

  Deposit.token deposit = Token "🍻"
  && Deposit.qty deposit = 1
  && Deposit.player_id deposit = player1.id
  && Deposit.about deposit = Some "TGIF"
  && Deposit.cooldown deposit = None

let%test "it gives 1 fire with cooldown" =
  let player1 = Player.make ~name:"player1" "player1" in
  let deposit =
    Deposit.give player1 "🔥"
      ~cooldown:Cooldown.(Hours 120)
      ~about:"hyper thanks"
  in
  Deposit.token deposit = Token "🔥"
  && Deposit.qty deposit = 1
  && Deposit.player_id deposit = player1.id
  && Deposit.about deposit = Some "hyper thanks"
  && Deposit.cooldown deposit = Some (120 * 3600)

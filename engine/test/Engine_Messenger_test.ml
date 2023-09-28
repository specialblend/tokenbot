open Tokenbot
open Engine
open System

module Fmt_test = struct
  let player1 = Player.make "player1"
  and player2 = Player.make "player2"
  and player3 = Player.make "player3"

  let sender = player1
  and recipients = [ player2; player3 ]

  let tokens = [ "🌮" ]
  let thanks = Thanks.make ~sender ~recipients ~tokens "example1"

  let rules = Rules.Collection.init ~dice:(Dice.dice_sequential ())
  and exchange = Rules.Exchange.exchange

  let received = Cashier.execute thanks ~rules ~exchange

  let%expect_test "formatting thanks" =
    print_endline (Receptionist.fmt_thanks received);
    [%expect
      {|
        <@player3>
        🌮 `x1 thanks`

        <@player2>
        🌮 `x1 thanks`

        <@player1>
        🏷️ `x2 receipt` |}]
end

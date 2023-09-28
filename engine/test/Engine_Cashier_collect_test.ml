open Tokenbot
open Engine
open System
open Test_util

let player1 = Player.make "player1"
and player2 = Player.make "player2"
and player3 = Player.make ~items:[] "player3"

let dice = Dice.dice_sequential ()
let rules = Rules.Collection.init ~dice

let sender = player1
and recipients = [ player2; player3 ]

module No_tokens_test = struct
  let tokens = []
  let thanks = Thanks.make ~sender ~recipients ~tokens "example1"
  let received = Cashier.collect_deposits thanks ~rules

  let%expect_test "🌮 snapshot" =
    List.iter print_deposit received;
    [%expect
      {|
        { player =
          { id = "player1"; name = "player"; tz_offset = 0; items = [];
            cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
            highscore = 0; luck = 0; is_bot = false };
          item = ("🏷️", 2); about = "receipt"; cooldown = None }
        ---
        { player =
          { id = "player2"; name = "player"; tz_offset = 0; items = [];
            cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
            highscore = 0; luck = 0; is_bot = false };
          item = ("🌮", 1); about = "thanks"; cooldown = None }
        ---
        { player =
          { id = "player3"; name = "player"; tz_offset = 0; items = [];
            cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
            highscore = 0; luck = 0; is_bot = false };
          item = ("🌮", 1); about = "thanks"; cooldown = None }
        --- |}]

  let%expect_test "🏷️x2 -> player1" =
    received
    |> List.filter (Deposit.belongs_to player1)
    |> List.map Deposit.item
    |> List.map Item.show
    |> List.iter print_endline;
    [%expect {| ("🏷️", 2) |}]

  let%expect_test "🌮x1 -> player2" =
    received
    |> List.filter (Deposit.belongs_to player2)
    |> List.map Deposit.item
    |> List.map Item.show
    |> List.iter print_endline;
    [%expect {| ("🌮", 1) |}]

  let%expect_test "🌮x1 -> player3" =
    received
    |> List.filter (Deposit.belongs_to player3)
    |> List.map Deposit.item
    |> List.map Item.show
    |> List.iter print_endline;
    [%expect {| ("🌮", 1) |}]
end

module Give_taco_test = struct
  let tokens = [ "🌮" ]
  let thanks = Thanks.make ~sender ~recipients ~tokens "example1"
  let received = Cashier.collect_deposits thanks ~rules

  let%expect_test "🌮 snapshot" =
    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "player1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🏷️", 2); about = "receipt"; cooldown = None }
      ---
      { player =
        { id = "player2"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🌮", 1); about = "thanks"; cooldown = None }
      ---
      { player =
        { id = "player3"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🌮", 1); about = "thanks"; cooldown = None }
      --- |}]

  let%expect_test "🏷️x2 -> player1" =
    received
    |> List.filter (Deposit.belongs_to player1)
    |> List.map Deposit.item
    |> List.map Item.show
    |> List.iter print_endline;
    [%expect {| ("🏷️", 2) |}]

  let%expect_test "🌮x1 -> player2" =
    received
    |> List.filter (Deposit.belongs_to player2)
    |> List.map Deposit.item
    |> List.map Item.show
    |> List.iter print_endline;
    [%expect {| ("🌮", 1) |}]

  let%expect_test "🌮x1 -> player3" =
    received
    |> List.filter (Deposit.belongs_to player3)
    |> List.map Deposit.item
    |> List.map Item.show
    |> List.iter print_endline;
    [%expect {| ("🌮", 1) |}]
end

module Give_pepper_test = struct
  let tokens = [ "🌶️" ]
  let thanks = Thanks.make ~sender ~recipients ~tokens "example1234"
  let received = Cashier.collect_deposits thanks ~rules

  let%expect_test "🌶️ snapshot" =
    List.iter print_deposit received;
    [%expect
      {|
        { player =
          { id = "player1"; name = "player"; tz_offset = 0; items = [];
            cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
            highscore = 0; luck = 0; is_bot = false };
          item = ("🏷️", 2); about = "receipt"; cooldown = None }
        ---
        { player =
          { id = "player2"; name = "player"; tz_offset = 0; items = [];
            cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
            highscore = 0; luck = 0; is_bot = false };
          item = ("🌶️", 1); about = "super thanks"; cooldown = (Some 28800) }
        ---
        { player =
          { id = "player3"; name = "player"; tz_offset = 0; items = [];
            cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
            highscore = 0; luck = 0; is_bot = false };
          item = ("🌶️", 1); about = "super thanks"; cooldown = (Some 28800) }
        --- |}]

  let%expect_test "🏷️x2 -> player1" =
    received
    |> List.filter (Deposit.belongs_to player1)
    |> List.map Deposit.item
    |> List.map Item.show
    |> List.iter print_endline;
    [%expect {| ("🏷️", 2) |}]

  let%expect_test "🌶️x1 -> player2" =
    received
    |> List.filter (Deposit.belongs_to player2)
    |> List.map Deposit.item
    |> List.map Item.show
    |> List.iter print_endline;
    [%expect {| ("🌶️", 1) |}]

  let%expect_test "🌶️x1 -> player3" =
    received
    |> List.filter (Deposit.belongs_to player3)
    |> List.map Deposit.item
    |> List.map Item.show
    |> List.iter print_endline;
    [%expect {| ("🌶️", 1) |}]
end

module Give_invalid_token_test = struct
  let tokens = [ "🏎️" ]
  let thanks = Thanks.make ~sender ~recipients ~tokens "example1234"
  let received = Cashier.collect_deposits thanks ~rules

  let%expect_test "🏎️ snapshot" =
    List.iter print_deposit received;
    [%expect
      {|
        { player =
          { id = "player1"; name = "player"; tz_offset = 0; items = [];
            cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
            highscore = 0; luck = 0; is_bot = false };
          item = ("🏷️", 2); about = "receipt"; cooldown = None }
        ---
        { player =
          { id = "player2"; name = "player"; tz_offset = 0; items = [];
            cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
            highscore = 0; luck = 0; is_bot = false };
          item = ("🌮", 1); about = "thanks"; cooldown = None }
        ---
        { player =
          { id = "player3"; name = "player"; tz_offset = 0; items = [];
            cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
            highscore = 0; luck = 0; is_bot = false };
          item = ("🌮", 1); about = "thanks"; cooldown = None }
        --- |}]

  let%expect_test "🏷️x2 -> player1" =
    received
    |> List.filter (Deposit.belongs_to player1)
    |> List.map Deposit.item
    |> List.map Item.show
    |> List.iter print_endline;
    [%expect {| ("🏷️", 2) |}]

  let%expect_test "🌮x1 -> player2" =
    received
    |> List.filter (Deposit.belongs_to player2)
    |> List.map Deposit.item
    |> List.map Item.show
    |> List.iter print_endline;
    [%expect {| ("🌮", 1) |}]

  let%expect_test "🌮x1 -> player3" =
    received
    |> List.filter (Deposit.belongs_to player3)
    |> List.map Deposit.item
    |> List.map Item.show
    |> List.iter print_endline;
    [%expect {| ("🌮", 1) |}]
end

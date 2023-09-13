open Tokenbot
open Engine
open System
open Test_util

let player1 = Player.make "player1"
let player2 = Player.make "player2"
let player3 = Player.make ~items:[ ("🔥", 1) ] "player3"
let deposit1 = Deposit.make ~player:player1 ~item:("🍻", 1) ()
let deposit2 = Deposit.make ~player:player2 ~item:("🌶️", 1) ()
let deposit3 = Deposit.make ~player:player3 ~item:("🍀", 1) ()
let deposit4 = Deposit.make ~player:player1 ~item:("🍻", 1) ()
let deposit5 = Deposit.make ~player:player2 ~item:("🌶️", 1) ()
let deposit6 = Deposit.make ~player:player3 ~item:("🍀", 1) ()
let deposit7 = Deposit.make ~player:player1 ~item:("☕️", 1) ()
let deposit8 = Deposit.make ~player:player2 ~item:("☕️", 1) ()

let deposit9 =
  Deposit.make ~player:player3
    ~cooldown:(Some (Clock.Duration.minutes 5))
    ~item:("☕️", 1) ()

let%expect_test "snapshot 1" =
  let deposits = [ deposit1; deposit2; deposit3 ]
  and players = [ player1; player2; player3 ] in

  players |> List.map (Cashier.distribute deposits) |> List.iter print_player;

  [%expect
    {|
      { id = "player1"; name = "player"; tz_offset = 0; items = [("🍻", 1)];
        cooldowns = []; score = { base = 1; bonus = 0; total = 1 }; highscore = 1;
        luck = 0; is_bot = false }
      ---
      { id = "player2"; name = "player"; tz_offset = 0; items = [("🌶️", 1)];
        cooldowns = []; score = { base = 3; bonus = 0; total = 3 }; highscore = 3;
        luck = 0; is_bot = false }
      ---
      { id = "player3"; name = "player"; tz_offset = 0;
        items = [("🍀", 1); ("🔥", 1)]; cooldowns = [];
        score = { base = 8; bonus = 1; total = 9 }; highscore = 9; luck = 20;
        is_bot = false }
      --- |}]

let%expect_test "snapshot 2" =
  let deposits =
    [
      deposit1;
      deposit2;
      deposit3;
      deposit4;
      deposit5;
      deposit6;
      deposit7;
      deposit8;
      deposit9;
    ]
  and players = [ player1; player2; player3 ] in

  players
  |> List.map (Cashier.distribute deposits)
  |> List.map Player.show
  |> List.iter (fun output ->
         print_endline output;
         [%expect
           {|
              (* CR expect_test: Collector ran multiple times with different outputs *)
              =========================================================================
              { id = "player1"; name = "player"; tz_offset = 0;
                items = [("☕️", 1); ("🍻", 2)]; cooldowns = [];
                score = { base = 3; bonus = 0; total = 3 }; highscore = 3; luck = 0;
                is_bot = false }

              =========================================================================
              { id = "player2"; name = "player"; tz_offset = 0;
                items = [("☕️", 1); ("🌶️", 2)]; cooldowns = [];
                score = { base = 7; bonus = 0; total = 7 }; highscore = 7; luck = 0;
                is_bot = false }

              =========================================================================
              { id = "player3"; name = "player"; tz_offset = 0;
                items = [("☕️", 1); ("🍀", 2); ("🔥", 1)]; cooldowns = [];
                score = { base = 10; bonus = 2; total = 12 }; highscore = 12; luck = 40;
                is_bot = false } |}])

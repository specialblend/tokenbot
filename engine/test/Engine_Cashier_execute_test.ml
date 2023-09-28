open Tokenbot
open Engine
open System

let player1 = Player.make "player1"
and player2 = Player.make "player2"
and player3 = Player.make ~items:[] "player3"

let dice = Dice.dice_sequential ()
let rules = Rules.Collection.init ~dice
let exchange = Rules.Exchange.exchange

let sender = player1
and recipients = [ player2; player3 ]

module No_tokens_test = struct
  let tokens = []
  let thanks = Thanks.make ~sender ~recipients ~tokens "example1"

  let%expect_test _ =
    let thanks = Cashier.execute thanks ~rules ~exchange in
    print_endline (Thanks.show thanks);

    [%expect
      {|
        { id = "example1";
          msg =
          { client_msg_id = "example_app_mention_id"; channel = "EXAMPLE";
            edited = None; event_ts = "0000000000.000000"; team = "TDEADBEEF";
            text = "Hello world"; thread_ts = None; ts = "0000000000.000000";
            user = "UDEADBEEF" };
          sender =
          { id = "player1"; name = "player"; tz_offset = 0; items = [("🏷️", 2)];
            cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
            highscore = 0; luck = 0; is_bot = false };
          recipients =
          [{ id = "player2"; name = "player"; tz_offset = 0; items = [("🌮", 1)];
             cooldowns = []; score = { base = 1; bonus = 0; total = 1 };
             highscore = 1; luck = 0; is_bot = false };
            { id = "player3"; name = "player"; tz_offset = 0; items = [("🌮", 1)];
              cooldowns = []; score = { base = 1; bonus = 0; total = 1 };
              highscore = 1; luck = 0; is_bot = false }
            ];
          tokens = [];
          deposits =
          [{ player =
             { id = "player1"; name = "player"; tz_offset = 0; items = [];
               cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
               highscore = 0; luck = 0; is_bot = false };
             item = ("🏷️", 2); about = "receipt"; cooldown = None };
            { player =
              { id = "player2"; name = "player"; tz_offset = 0; items = [];
                cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
                highscore = 0; luck = 0; is_bot = false };
              item = ("🌮", 1); about = "thanks"; cooldown = None };
            { player =
              { id = "player3"; name = "player"; tz_offset = 0; items = [];
                cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
                highscore = 0; luck = 0; is_bot = false };
              item = ("🌮", 1); about = "thanks"; cooldown = None }
            ]
          } |}]
end

module Thanks_test = struct
  let tokens = [ "🌮" ]
  let thanks = Thanks.make ~sender ~recipients ~tokens "example1"

  let%expect_test "thanks show" =
    let thanks = Cashier.execute thanks ~rules ~exchange in
    print_endline (Thanks.show thanks);

    [%expect
      {|
        { id = "example1";
          msg =
          { client_msg_id = "example_app_mention_id"; channel = "EXAMPLE";
            edited = None; event_ts = "0000000000.000000"; team = "TDEADBEEF";
            text = "Hello world"; thread_ts = None; ts = "0000000000.000000";
            user = "UDEADBEEF" };
          sender =
          { id = "player1"; name = "player"; tz_offset = 0; items = [("🏷️", 2)];
            cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
            highscore = 0; luck = 0; is_bot = false };
          recipients =
          [{ id = "player2"; name = "player"; tz_offset = 0; items = [("🌮", 1)];
             cooldowns = []; score = { base = 1; bonus = 0; total = 1 };
             highscore = 1; luck = 0; is_bot = false };
            { id = "player3"; name = "player"; tz_offset = 0; items = [("🌮", 1)];
              cooldowns = []; score = { base = 1; bonus = 0; total = 1 };
              highscore = 1; luck = 0; is_bot = false }
            ];
          tokens = ["\240\159\140\174"];
          deposits =
          [{ player =
             { id = "player1"; name = "player"; tz_offset = 0; items = [];
               cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
               highscore = 0; luck = 0; is_bot = false };
             item = ("🏷️", 2); about = "receipt"; cooldown = None };
            { player =
              { id = "player2"; name = "player"; tz_offset = 0; items = [];
                cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
                highscore = 0; luck = 0; is_bot = false };
              item = ("🌮", 1); about = "thanks"; cooldown = None };
            { player =
              { id = "player3"; name = "player"; tz_offset = 0; items = [];
                cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
                highscore = 0; luck = 0; is_bot = false };
              item = ("🌮", 1); about = "thanks"; cooldown = None }
            ]
          } |}]
end

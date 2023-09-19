open Tokenbot
open System
open Fun

let print_deposit deposit =
  print_endline (Thanks.Deposit.show deposit);
  print_endline "---"

module Base_token_test = struct
  let sender = Player.make "example_sender1"
  let recipient1 = Player.make "example_recipient1"
  let recipient2 = Player.make "example_recipient2"
  let recipients = [ recipient1; recipient2 ]

  module No_tokens_test = struct
    let tokens = []
    let thanks = Thanks.make ~sender ~recipients ~tokens "example_thanks"
    let received = Rules.Collection.base thanks []

    let%expect_test "snapshot" =
      List.iter print_deposit received;
      [%expect
        {|
        { player =
          { id = "example_sender1"; name = "player"; tz_offset = 0; items = [];
            cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
            highscore = 0; luck = 0; is_bot = false };
          item = ("🏷️", 2); about = "receipt"; cooldown = None }
        ---
        { player =
          { id = "example_recipient1"; name = "player"; tz_offset = 0; items = [];
            cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
            highscore = 0; luck = 0; is_bot = false };
          item = ("🌮", 1); about = "thanks"; cooldown = None }
        ---
        { player =
          { id = "example_recipient2"; name = "player"; tz_offset = 0; items = [];
            cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
            highscore = 0; luck = 0; is_bot = false };
          item = ("🌮", 1); about = "thanks"; cooldown = None }
        --- |}]
  end

  module Duplicate_tokens_test = struct
    let tokens = [ "🌮"; "🌶️"; "🔥"; "🌮"; "🌶️"; "🔥"; "🌮"; "🌶️"; "🔥" ]

    let recipients = [ recipient1 ]
    let thanks = Thanks.make ~sender ~recipients ~tokens "example_thanks"
    let received = Rules.Collection.base thanks []

    let%expect_test "Duplicate_tokens_test" =
      List.iter print_deposit received;
      [%expect
        {|
        { player =
          { id = "example_sender1"; name = "player"; tz_offset = 0; items = [];
            cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
            highscore = 0; luck = 0; is_bot = false };
          item = ("🏷️", 1); about = "receipt"; cooldown = None }
        ---
        { player =
          { id = "example_recipient1"; name = "player"; tz_offset = 0; items = [];
            cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
            highscore = 0; luck = 0; is_bot = false };
          item = ("🌮", 1); about = "thanks"; cooldown = None }
        ---
        { player =
          { id = "example_recipient1"; name = "player"; tz_offset = 0; items = [];
            cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
            highscore = 0; luck = 0; is_bot = false };
          item = ("🌶️", 1); about = "super thanks"; cooldown = (Some 28800) }
        ---
        { player =
          { id = "example_recipient1"; name = "player"; tz_offset = 0; items = [];
            cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
            highscore = 0; luck = 0; is_bot = false };
          item = ("🔥", 1); about = "hyper thanks"; cooldown = (Some 432000) }
        --- |}]

    let%test "🌮x1 -> recipient" =
      received
      |> List.filter (Thanks.Deposit.belongs_to recipient1)
      |> List.filter (Thanks.Deposit.token_eq "🌮")
      |> List.map Thanks.Deposit.item
      |> function
      | [ ("🌮", 1) ] -> true
      | _ -> false

    let%test "🌶️x1 -> recipient" =
      received
      |> List.filter (Thanks.Deposit.belongs_to recipient1)
      |> List.filter (Thanks.Deposit.token_eq "🌶️")
      |> List.map Thanks.Deposit.item
      |> function
      | [ ("🌶️", 1) ] -> true
      | _ -> false

    let%test "🔥x1 -> recipient" =
      received
      |> List.filter (Thanks.Deposit.belongs_to recipient1)
      |> List.filter (Thanks.Deposit.token_eq "🔥")
      |> List.map Thanks.Deposit.item
      |> function
      | [ ("🔥", 1) ] -> true
      | _ -> false

    let%test "🏷️x1 -> sender" =
      received
      |> List.filter (Thanks.Deposit.belongs_to sender)
      |> List.map Thanks.Deposit.item
      |> function
      | [ ("🏷️", 1) ] -> true
      | _ -> false
  end

  module Super_thanks_test = struct
    let tokens = [ "🌶️" ]

    module No_cooldown_test = struct
      let thanks = Thanks.make ~sender ~recipients ~tokens "example_thanks"
      let received = Rules.Collection.base thanks []

      let%expect_test "snapshot" =
        List.iter print_deposit received;
        [%expect
          {|
          { player =
            { id = "example_sender1"; name = "player"; tz_offset = 0; items = [];
              cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
              highscore = 0; luck = 0; is_bot = false };
            item = ("🏷️", 2); about = "receipt"; cooldown = None }
          ---
          { player =
            { id = "example_recipient1"; name = "player"; tz_offset = 0; items = [];
              cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
              highscore = 0; luck = 0; is_bot = false };
            item = ("🌶️", 1); about = "super thanks"; cooldown = (Some 28800) }
          ---
          { player =
            { id = "example_recipient2"; name = "player"; tz_offset = 0; items = [];
              cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
              highscore = 0; luck = 0; is_bot = false };
            item = ("🌶️", 1); about = "super thanks"; cooldown = (Some 28800) }
          --- |}]
    end

    module Cooldown_test = struct
      let cooldowns = [ ("🌶️", Clock.Duration.hours 8) ]
      let sender = Player.make ~cooldowns "example_sender1"
      let thanks = Thanks.make ~sender ~recipients ~tokens "example_thanks"
      let received = Rules.Collection.base thanks []

      let%expect_test "snapshot" =
        List.iter print_deposit received;
        [%expect
          {|
          { player =
            { id = "example_sender1"; name = "player"; tz_offset = 0; items = [];
              cooldowns = [("🌶️", 28800)];
              score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
              is_bot = false };
            item = ("🏷️", 2); about = "receipt"; cooldown = None }
          ---
          { player =
            { id = "example_sender1"; name = "player"; tz_offset = 0; items = [];
              cooldowns = [("🌶️", 28800)];
              score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
              is_bot = false };
            item = ("⚠️", 1); about = "cooldown warning for 🌶️ (~8 hours)";
            cooldown = None }
          ---
          { player =
            { id = "example_recipient1"; name = "player"; tz_offset = 0; items = [];
              cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
              highscore = 0; luck = 0; is_bot = false };
            item = ("🌮", 1); about = "thanks"; cooldown = None }
          ---
          { player =
            { id = "example_recipient2"; name = "player"; tz_offset = 0; items = [];
              cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
              highscore = 0; luck = 0; is_bot = false };
            item = ("🌮", 1); about = "thanks"; cooldown = None }
          --- |}]
    end
  end

  module Hyper_thanks_test = struct
    let tokens = [ "🔥" ]

    module No_cooldown_test = struct
      let thanks = Thanks.make ~sender ~recipients ~tokens "example_thanks"
      let received = Rules.Collection.base thanks []

      let%expect_test "snapshot" =
        List.iter print_deposit received;
        [%expect
          {|
          { player =
            { id = "example_sender1"; name = "player"; tz_offset = 0; items = [];
              cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
              highscore = 0; luck = 0; is_bot = false };
            item = ("🏷️", 2); about = "receipt"; cooldown = None }
          ---
          { player =
            { id = "example_recipient1"; name = "player"; tz_offset = 0; items = [];
              cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
              highscore = 0; luck = 0; is_bot = false };
            item = ("🔥", 1); about = "hyper thanks"; cooldown = (Some 432000) }
          ---
          { player =
            { id = "example_recipient2"; name = "player"; tz_offset = 0; items = [];
              cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
              highscore = 0; luck = 0; is_bot = false };
            item = ("🔥", 1); about = "hyper thanks"; cooldown = (Some 432000) }
          --- |}]
    end

    module Cooldown_test = struct
      let cooldowns = [ ("🔥", Clock.Duration.hours 120) ]
      let sender = Player.make ~cooldowns "example_sender1"
      let thanks = Thanks.make ~sender ~recipients ~tokens "example_thanks"
      let received = Rules.Collection.base thanks []

      let%expect_test "snapshot" =
        List.iter print_deposit received;
        [%expect
          {|
          { player =
            { id = "example_sender1"; name = "player"; tz_offset = 0; items = [];
              cooldowns = [("🔥", 432000)];
              score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
              is_bot = false };
            item = ("🏷️", 2); about = "receipt"; cooldown = None }
          ---
          { player =
            { id = "example_sender1"; name = "player"; tz_offset = 0; items = [];
              cooldowns = [("🔥", 432000)];
              score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
              is_bot = false };
            item = ("⚠️", 1); about = "cooldown warning for 🔥 (~120 hours)";
            cooldown = None }
          ---
          { player =
            { id = "example_recipient1"; name = "player"; tz_offset = 0; items = [];
              cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
              highscore = 0; luck = 0; is_bot = false };
            item = ("🌮", 1); about = "thanks"; cooldown = None }
          ---
          { player =
            { id = "example_recipient2"; name = "player"; tz_offset = 0; items = [];
              cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
              highscore = 0; luck = 0; is_bot = false };
            item = ("🌮", 1); about = "thanks"; cooldown = None }
          --- |}]
    end
  end

  module Invalid_tokens_test = struct
    let tokens = [ "🚗"; "🏎️" ]
    let thanks = Thanks.make ~sender ~recipients ~tokens "example_thanks"
    let received = Rules.Collection.base thanks []

    let%expect_test "fallback token" =
      List.iter print_deposit received;
      [%expect
        {|
          { player =
            { id = "example_sender1"; name = "player"; tz_offset = 0; items = [];
              cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
              highscore = 0; luck = 0; is_bot = false };
            item = ("🏷️", 2); about = "receipt"; cooldown = None }
          ---
          { player =
            { id = "example_recipient1"; name = "player"; tz_offset = 0; items = [];
              cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
              highscore = 0; luck = 0; is_bot = false };
            item = ("🌮", 1); about = "thanks"; cooldown = None }
          ---
          { player =
            { id = "example_recipient2"; name = "player"; tz_offset = 0; items = [];
              cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
              highscore = 0; luck = 0; is_bot = false };
            item = ("🌮", 1); about = "thanks"; cooldown = None }
          --- |}]
  end

  module Non_givable_tokens_test = struct
    let tokens = [ "🍀"; "💀" ]
    let thanks = Thanks.make ~sender ~recipients ~tokens "example_thanks"
    let received = Rules.Collection.base thanks []

    let%expect_test "fallback token" =
      List.iter print_deposit received;
      [%expect
        {|
          { player =
            { id = "example_sender1"; name = "player"; tz_offset = 0; items = [];
              cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
              highscore = 0; luck = 0; is_bot = false };
            item = ("🏷️", 2); about = "receipt"; cooldown = None }
          ---
          { player =
            { id = "example_recipient1"; name = "player"; tz_offset = 0; items = [];
              cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
              highscore = 0; luck = 0; is_bot = false };
            item = ("🌮", 1); about = "thanks"; cooldown = None }
          ---
          { player =
            { id = "example_recipient2"; name = "player"; tz_offset = 0; items = [];
              cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
              highscore = 0; luck = 0; is_bot = false };
            item = ("🌮", 1); about = "thanks"; cooldown = None }
          --- |}]
  end
end

module Monday_test = struct
  let sender = Player.make "example_sender1"
  let recipient1 = Player.make "example_recipient1"
  let recipient2 = Player.make "example_recipient2"
  let recipients = [ recipient1; recipient2 ]

  let%expect_test "no ☕️ on sunday" =
    let ts = "1693774188.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.monday thanks [] in

    List.iter print_deposit received;
    [%expect {||}]

  let%expect_test "☕️x1 on monday" =
    let ts = "1693860588.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.monday thanks [] in

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_recipient1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("☕️", 1); about = "monday"; cooldown = None }
      ---
      { player =
        { id = "example_recipient2"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("☕️", 1); about = "monday"; cooldown = None }
      --- |}]

  let%expect_test "no ☕️on tuesday" =
    let ts = "1693946988.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.monday thanks [] in

    List.iter print_deposit received;
    [%expect {||}]

  let%expect_test "no ☕️on wednesday" =
    let ts = "1694033388.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.monday thanks [] in

    List.iter print_deposit received;
    [%expect {||}]

  let%expect_test "no ☕️on thursday" =
    let ts = "1694119788.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.monday thanks [] in

    List.iter print_deposit received;
    [%expect {||}]

  let%expect_test "no ☕️on friday" =
    let ts = "1694206188.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.monday thanks [] in

    List.iter print_deposit received;
    [%expect {||}]

  let%expect_test "no ☕️on saturday" =
    let ts = "1694292588.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.monday thanks [] in

    List.iter print_deposit received;
    [%expect {||}]
end

module Friday_test = struct
  let sender = Player.make "example_sender1"
  let recipient1 = Player.make "example_recipient1"
  let recipient2 = Player.make "example_recipient2"
  let recipients = [ recipient1; recipient2 ]

  let%expect_test "no 🍻on sunday" =
    let ts = "1693774188.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.friday thanks [] in

    List.iter print_deposit received;
    [%expect {||}]

  let%expect_test "no 🍻on monday" =
    let ts = "1693860588.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.friday thanks [] in

    List.iter print_deposit received;
    [%expect {| |}]

  let%expect_test "no 🍻on tuesday" =
    let ts = "1693946988.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.friday thanks [] in

    List.iter print_deposit received;
    [%expect {||}]

  let%expect_test "no 🍻on wednesday" =
    let ts = "1694033388.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.friday thanks [] in

    List.iter print_deposit received;
    [%expect {||}]

  let%expect_test "no 🍻on thursday" =
    let ts = "1694119788.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.friday thanks [] in

    List.iter print_deposit received;
    [%expect {||}]

  let%expect_test "🍻x1 -> everyone on friday" =
    let ts = "1694206188.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.friday thanks [] in

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_recipient1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🍻", 1); about = "TGIF"; cooldown = None }
      ---
      { player =
        { id = "example_recipient2"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🍻", 1); about = "TGIF"; cooldown = None }
      --- |}]

  let%expect_test "no 🍻on saturday" =
    let ts = "1694292588.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.friday thanks [] in

    List.iter print_deposit received;
    [%expect {||}]
end

module Happy_hour_test = struct
  let sender = Player.make "example_sender1"
  let recipient1 = Player.make "example_recipient1"
  let recipient2 = Player.make "example_recipient2"
  let recipients = [ recipient1; recipient2 ]
  let ts_of_hour n = Fmt.sprintf "%d.000000" (n * 3600)

  let print_hours thx =
    thx
    |> Thanks.everyone
    |> List.iter (fun player ->
           let hour = Clock.hour (Thanks.local_time thx player) in
           print_endline (Fmt.sprintf "%s -> %d" (Player.id player) hour))

  let%expect_test "no 🍻 before 1600 hours" =
    let ts = ts_of_hour 15 in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.happy_hour thanks [] in

    print_hours thanks;
    [%expect
      {|
      example_sender1 -> 15
      example_recipient1 -> 15
      example_recipient2 -> 15 |}];

    List.iter print_deposit received;
    [%expect {||}]

  let%expect_test "no 🍻 after 1800 hours" =
    let ts = ts_of_hour 19 in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.happy_hour thanks [] in

    print_hours thanks;
    [%expect
      {|
      example_sender1 -> 19
      example_recipient1 -> 19
      example_recipient2 -> 19 |}];

    List.iter print_deposit received;
    [%expect {||}]

  let%expect_test "🍻x1 -> everyone at 1600 hours" =
    let ts = ts_of_hour 16 in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.happy_hour thanks [] in

    print_hours thanks;
    [%expect
      {|
          example_sender1 -> 16
          example_recipient1 -> 16
          example_recipient2 -> 16 |}];

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_sender1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🍻", 1); about = "happy hour"; cooldown = None }
      ---
      { player =
        { id = "example_recipient1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🍻", 1); about = "happy hour"; cooldown = None }
      ---
      { player =
        { id = "example_recipient2"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🍻", 1); about = "happy hour"; cooldown = None }
      --- |}]

  let%expect_test "🍻x1 -> everyone at 1700 hours" =
    let ts = ts_of_hour 17 in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.happy_hour thanks [] in

    print_hours thanks;
    [%expect
      {|
          example_sender1 -> 17
          example_recipient1 -> 17
          example_recipient2 -> 17 |}];

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_sender1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🍻", 1); about = "happy hour"; cooldown = None }
      ---
      { player =
        { id = "example_recipient1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🍻", 1); about = "happy hour"; cooldown = None }
      ---
      { player =
        { id = "example_recipient2"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🍻", 1); about = "happy hour"; cooldown = None }
      --- |}]

  let%expect_test "no 🍻 at 1800 hours" =
    let ts = ts_of_hour 18 in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.happy_hour thanks [] in

    print_hours thanks;
    [%expect
      {|
      example_sender1 -> 18
      example_recipient1 -> 18
      example_recipient2 -> 18 |}];

    List.iter print_deposit received;
    [%expect {| |}]
end

module St_paddy_test = struct
  let sender = Player.make "example_sender1"
  let recipient1 = Player.make "example_recipient1"
  let recipient2 = Player.make "example_recipient2"
  let recipients = [ recipient1; recipient2 ]

  let print_dates thanks =
    List.iter
      (fun player ->
        let id = Player.id player in
        let now = Thanks.local_time thanks player in
        let month, mday = Clock.(month now, mday now) in
        print_endline (Fmt.sprintf "%s -> %d/%d" id month mday))
      (Thanks.everyone thanks)

  let%expect_test "no 🍀 before 3/17" =
    let ts = "1710612366.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.st_paddy thanks [] in

    print_dates thanks;
    [%expect
      {|
      example_sender1 -> 3/16
      example_recipient1 -> 3/16
      example_recipient2 -> 3/16 |}];

    List.iter print_deposit received;
    [%expect {||}]

  let%expect_test "🍀x1 -> everyone on 3/17" =
    let ts = "1710698766.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.st_paddy thanks [] in

    print_dates thanks;
    [%expect
      {|
      example_sender1 -> 3/17
      example_recipient1 -> 3/17
      example_recipient2 -> 3/17 |}];

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_sender1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🍀", 1); about = "st paddy"; cooldown = None }
      ---
      { player =
        { id = "example_recipient1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🍀", 1); about = "st paddy"; cooldown = None }
      ---
      { player =
        { id = "example_recipient2"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🍀", 1); about = "st paddy"; cooldown = None }
      --- |}]

  let%expect_test "🍀x1 -> everyone on 3/18" =
    let ts = "1710785166.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.st_paddy thanks [] in

    print_dates thanks;
    [%expect
      {|
      example_sender1 -> 3/18
      example_recipient1 -> 3/18
      example_recipient2 -> 3/18 |}];

    List.iter print_deposit received;
    [%expect {||}]

  let%expect_test "no 🍀 after 3/18" =
    let ts = "1710871566.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.st_paddy thanks [] in

    print_dates thanks;
    [%expect
      {|
      example_sender1 -> 3/19
      example_recipient1 -> 3/19
      example_recipient2 -> 3/19 |}];

    List.iter print_deposit received;
    [%expect {||}]
end

module Halloween_test = struct
  let sender = Player.make "example_sender1"
  let recipient1 = Player.make "example_recipient1"
  let recipient2 = Player.make "example_recipient2"
  let recipients = [ recipient1; recipient2 ]

  let print_dates thanks =
    List.iter
      (fun player ->
        let id = Player.id player in
        let now = Thanks.local_time thanks player in
        let month, mday = Clock.(month now, mday now) in
        print_endline (Fmt.sprintf "%s -> %d/%d" id month mday))
      (Thanks.everyone thanks)

  let%expect_test "no 🎃 before 10/21" =
    let ts = "1697825166.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.halloween thanks [] in

    print_dates thanks;
    [%expect
      {|
      example_sender1 -> 10/20
      example_recipient1 -> 10/20
      example_recipient2 -> 10/20 |}];

    List.iter print_deposit received;
    [%expect {||}]

  let%expect_test "🎃x1 -> everyone on 10/21" =
    let ts = "1697911566.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.halloween thanks [] in

    print_dates thanks;
    [%expect
      {|
      example_sender1 -> 10/21
      example_recipient1 -> 10/21
      example_recipient2 -> 10/21 |}];

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_sender1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🎃", 1); about = "trick or treat"; cooldown = None }
      ---
      { player =
        { id = "example_recipient1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🎃", 1); about = "trick or treat"; cooldown = None }
      ---
      { player =
        { id = "example_recipient2"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🎃", 1); about = "trick or treat"; cooldown = None }
      --- |}]

  let%expect_test "🎃x1 -> everyone on 10/31" =
    let ts = "1698775566.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.halloween thanks [] in

    print_dates thanks;
    [%expect
      {|
      example_sender1 -> 10/31
      example_recipient1 -> 10/31
      example_recipient2 -> 10/31 |}];

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_sender1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🎃", 1); about = "trick or treat"; cooldown = None }
      ---
      { player =
        { id = "example_recipient1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🎃", 1); about = "trick or treat"; cooldown = None }
      ---
      { player =
        { id = "example_recipient2"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🎃", 1); about = "trick or treat"; cooldown = None }
      --- |}]

  let%expect_test "no 🎃 after 10/31" =
    let ts = "1698861966.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.halloween thanks [] in

    print_dates thanks;
    [%expect
      {|
      example_sender1 -> 11/1
      example_recipient1 -> 11/1
      example_recipient2 -> 11/1 |}];

    List.iter print_deposit received;
    [%expect {||}]
end

module Holiday_season_test = struct
  let sender = Player.make "example_sender1"
  let recipient1 = Player.make "example_recipient1"
  let recipient2 = Player.make "example_recipient2"
  let recipients = [ recipient1; recipient2 ]

  let print_dates thanks =
    List.iter
      (fun player ->
        let id = Player.id player in
        let now = Thanks.local_time thanks player in
        let month, mday = Clock.(month now, mday now) in
        print_endline (Fmt.sprintf "%s -> %d/%d" id month mday))
      (Thanks.everyone thanks)

  let%expect_test "no 🎁 before 12/21" =
    let ts = "1703095566.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.holiday_season thanks [] in

    print_dates thanks;
    [%expect
      {|
      example_sender1 -> 12/20
      example_recipient1 -> 12/20
      example_recipient2 -> 12/20 |}];

    List.iter print_deposit received;
    [%expect {||}]

  let%expect_test "🎁x1 -> everyone on 12/21" =
    let ts = "1703181966.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.holiday_season thanks [] in

    print_dates thanks;
    [%expect
      {|
      example_sender1 -> 12/21
      example_recipient1 -> 12/21
      example_recipient2 -> 12/21 |}];

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_sender1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🎁", 1); about = "happy holidays"; cooldown = None }
      ---
      { player =
        { id = "example_recipient1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🎁", 1); about = "happy holidays"; cooldown = None }
      ---
      { player =
        { id = "example_recipient2"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🎁", 1); about = "happy holidays"; cooldown = None }
      --- |}]

  let%expect_test "🎁x1 -> everyone on 12/31" =
    let ts = "1704045966.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.holiday_season thanks [] in

    print_dates thanks;
    [%expect
      {|
      example_sender1 -> 12/31
      example_recipient1 -> 12/31
      example_recipient2 -> 12/31 |}];

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_sender1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🎁", 1); about = "happy holidays"; cooldown = None }
      ---
      { player =
        { id = "example_recipient1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🎁", 1); about = "happy holidays"; cooldown = None }
      ---
      { player =
        { id = "example_recipient2"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🎁", 1); about = "happy holidays"; cooldown = None }
      --- |}]

  let%expect_test "no 🎁 after 12/31" =
    let ts = "1704132366.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.holiday_season thanks [] in

    print_dates thanks;
    [%expect
      {|
      example_sender1 -> 1/1
      example_recipient1 -> 1/1
      example_recipient2 -> 1/1 |}];

    List.iter print_deposit received;
    [%expect {||}]
end

module Navruz_test = struct
  let sender = Player.make "example_sender1"
  let recipient1 = Player.make "example_recipient1"
  let recipient2 = Player.make "example_recipient2"
  let recipients = [ recipient1; recipient2 ]

  let print_dates thanks =
    List.iter
      (fun player ->
        let id = Player.id player in
        let now = Thanks.local_time thanks player in
        let month, mday = Clock.(month now, mday now) in
        print_endline (Fmt.sprintf "%s -> %d/%d" id month mday))
      (Thanks.everyone thanks)

  let%expect_test "no 🔥 before 3/21" =
    let ts = "1710957966.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.navruz thanks [] in

    print_dates thanks;
    [%expect
      {|
      example_sender1 -> 3/20
      example_recipient1 -> 3/20
      example_recipient2 -> 3/20 |}];

    List.iter print_deposit received;
    [%expect {||}]

  let%expect_test "🔥x1 -> everyone on 3/21" =
    let ts = "1711044366.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.navruz thanks [] in

    print_dates thanks;
    [%expect
      {|
      example_sender1 -> 3/21
      example_recipient1 -> 3/21
      example_recipient2 -> 3/21 |}];

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_sender1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🔥", 1); about = "happy navruz"; cooldown = None }
      ---
      { player =
        { id = "example_recipient1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🔥", 1); about = "happy navruz"; cooldown = None }
      ---
      { player =
        { id = "example_recipient2"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🔥", 1); about = "happy navruz"; cooldown = None }
      --- |}]

  let%expect_test "🔥x1 -> everyone on 3/31" =
    let ts = "1711908366.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.navruz thanks [] in

    print_dates thanks;
    [%expect
      {|
      example_sender1 -> 3/31
      example_recipient1 -> 3/31
      example_recipient2 -> 3/31 |}];

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_sender1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🔥", 1); about = "happy navruz"; cooldown = None }
      ---
      { player =
        { id = "example_recipient1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🔥", 1); about = "happy navruz"; cooldown = None }
      ---
      { player =
        { id = "example_recipient2"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("🔥", 1); about = "happy navruz"; cooldown = None }
      --- |}]

  let%expect_test "no 🔥 after 3/31" =
    let ts = "1711994766.000000" in
    let msg = Slack.AppMention.make ~ts ~text:"hello" () in
    let thanks = Thanks.make ~sender ~recipients ~msg "example_thanks" in
    let received = Rules.Collection.navruz thanks [] in

    print_dates thanks;
    [%expect
      {|
      example_sender1 -> 4/1
      example_recipient1 -> 4/1
      example_recipient2 -> 4/1 |}];

    List.iter print_deposit received;
    [%expect {||}]
end

module Lucky_test = struct
  let print_luck thanks =
    List.iter
      (fun player ->
        let id = Player.id player in
        let luck = Player.luck player in
        print_endline (Fmt.sprintf "%s -> %d" id luck))
      (Thanks.everyone thanks)

  let%expect_test "no 🎁 when luck is 0 and dice rolls 1" =
    let sender = Player.make "example_sender1"
    and recipient1 = Player.make "example_recipient1"
    and recipient2 = Player.make "example_recipient2" in
    let recipients = [ recipient1; recipient2 ] in

    let dice _ = 1 in
    print_int (dice 100);
    [%expect {| 1 |}];

    let thanks = Thanks.make ~sender ~recipients "example_thanks" in
    let received = Rules.Collection.lucky thanks [] ~dice in

    print_luck thanks;
    [%expect
      {|
      example_sender1 -> 0
      example_recipient1 -> 0
      example_recipient2 -> 0 |}];

    List.iter print_deposit received;
    [%expect {||}]

  let%expect_test "no 🎁 when luck is 0 and dice rolls 50" =
    let sender = Player.make "example_sender1"
    and recipient1 = Player.make "example_recipient1"
    and recipient2 = Player.make "example_recipient2" in
    let recipients = [ recipient1; recipient2 ] in

    let dice _ = 50 in
    print_int (dice 100);
    [%expect {| 50 |}];

    let thanks = Thanks.make ~sender ~recipients "example_thanks" in
    let received = Rules.Collection.lucky thanks [] ~dice in

    print_luck thanks;
    [%expect
      {|
      example_sender1 -> 0
      example_recipient1 -> 0
      example_recipient2 -> 0 |}];

    List.iter print_deposit received;
    [%expect {||}]

  let%expect_test "no 🎁 when luck is 0 and dice rolls 100" =
    let sender = Player.make "example_sender1"
    and recipient1 = Player.make "example_recipient1"
    and recipient2 = Player.make "example_recipient2" in
    let recipients = [ recipient1; recipient2 ] in

    let dice _ = 100 in
    print_int (dice 100);
    [%expect {| 100 |}];

    let thanks = Thanks.make ~sender ~recipients "example_thanks" in
    let received = Rules.Collection.lucky thanks [] ~dice in

    print_luck thanks;
    [%expect
      {|
          example_sender1 -> 0
          example_recipient1 -> 0
          example_recipient2 -> 0 |}];

    List.iter print_deposit received;
    [%expect {||}]

  let%expect_test "no 🎁 when luck is 20 and dice rolls 20" =
    let items = [ ("🍀", 1) ] in
    let sender = Player.make ~items "example_sender1"
    and recipient1 = Player.make ~items "example_recipient1"
    and recipient2 = Player.make ~items "example_recipient2" in
    let recipients = [ recipient1; recipient2 ] in

    let dice _ = 20 in
    print_int (dice 100);
    [%expect {| 20 |}];

    let thanks = Thanks.make ~sender ~recipients "example_thanks" in
    let received = Rules.Collection.lucky thanks [] ~dice in

    print_luck thanks;
    [%expect
      {|
              example_sender1 -> 20
              example_recipient1 -> 20
              example_recipient2 -> 20 |}];

    List.iter print_deposit received;
    [%expect {| |}]

  let%expect_test "no 🎁 when luck is 20 and dice rolls 21" =
    let items = [ ("🍀", 1) ] in
    let sender = Player.make ~items "example_sender1"
    and recipient1 = Player.make ~items "example_recipient1"
    and recipient2 = Player.make ~items "example_recipient2" in
    let recipients = [ recipient1; recipient2 ] in

    let dice _ = 21 in
    print_int (dice 100);
    [%expect {| 21 |}];

    let thanks = Thanks.make ~sender ~recipients "example_thanks" in
    let received = Rules.Collection.lucky thanks [] ~dice in

    print_luck thanks;
    [%expect
      {|
                    example_sender1 -> 20
                    example_recipient1 -> 20
                    example_recipient2 -> 20 |}];

    List.iter print_deposit received;
    [%expect {| |}]

  let%expect_test "no 🎁 when luck is 40 and dice rolls 40" =
    let items = [ ("🍀", 2) ] in
    let sender = Player.make ~items "example_sender1"
    and recipient1 = Player.make ~items "example_recipient1"
    and recipient2 = Player.make ~items "example_recipient2" in
    let recipients = [ recipient1; recipient2 ] in

    let dice _ = 40 in
    print_int (dice 100);
    [%expect {| 40 |}];

    let thanks = Thanks.make ~sender ~recipients "example_thanks" in
    let received = Rules.Collection.lucky thanks [] ~dice in

    print_luck thanks;
    [%expect
      {|
              example_sender1 -> 40
              example_recipient1 -> 40
              example_recipient2 -> 40 |}];

    List.iter print_deposit received;
    [%expect {| |}]

  let%expect_test "no 🎁 when luck is 60 and dice rolls 60" =
    let items = [ ("🍀", 3) ] in
    let sender = Player.make ~items "example_sender1"
    and recipient1 = Player.make ~items "example_recipient1"
    and recipient2 = Player.make ~items "example_recipient2" in
    let recipients = [ recipient1; recipient2 ] in

    let dice _ = 60 in
    print_int (dice 100);
    [%expect {| 60 |}];

    let thanks = Thanks.make ~sender ~recipients "example_thanks" in
    let received = Rules.Collection.lucky thanks [] ~dice in

    print_luck thanks;
    [%expect
      {|
              example_sender1 -> 60
              example_recipient1 -> 60
              example_recipient2 -> 60 |}];

    List.iter print_deposit received;
    [%expect {| |}]

  let%expect_test "no 🎁 when luck is 80 and dice rolls 80" =
    let items = [ ("🍀", 4) ] in
    let sender = Player.make ~items "example_sender1"
    and recipient1 = Player.make ~items "example_recipient1"
    and recipient2 = Player.make ~items "example_recipient2" in
    let recipients = [ recipient1; recipient2 ] in

    let dice _ = 80 in
    print_int (dice 100);
    [%expect {| 80 |}];

    let thanks = Thanks.make ~sender ~recipients "example_thanks" in
    let received = Rules.Collection.lucky thanks [] ~dice in

    print_luck thanks;
    [%expect
      {|
              example_sender1 -> 80
              example_recipient1 -> 80
              example_recipient2 -> 80 |}];

    List.iter print_deposit received;
    [%expect {| |}]

  let%expect_test "no 🎁 when luck is 100 and dice rolls 100" =
    let items = [ ("🍀", 5) ] in
    let sender = Player.make ~items "example_sender1"
    and recipient1 = Player.make ~items "example_recipient1"
    and recipient2 = Player.make ~items "example_recipient2" in
    let recipients = [ recipient1; recipient2 ] in

    let dice _ = 100 in
    print_int (dice 100);
    [%expect {| 100 |}];

    let thanks = Thanks.make ~sender ~recipients "example_thanks" in
    let received = Rules.Collection.lucky thanks [] ~dice in

    print_luck thanks;
    [%expect
      {|
              example_sender1 -> 100
              example_recipient1 -> 100
              example_recipient2 -> 100 |}];

    List.iter print_deposit received;
    [%expect {| |}]

  let%expect_test "🎁x1 -> recipients when luck is 20 and dice rolls 1" =
    let items = [ ("🍀", 1) ] in
    let sender = Player.make ~items "example_sender1"
    and recipient1 = Player.make ~items "example_recipient1"
    and recipient2 = Player.make ~items "example_recipient2" in
    let recipients = [ recipient1; recipient2 ] in

    let dice _ = 1 in
    print_int (dice 100);
    [%expect {| 1 |}];

    let thanks = Thanks.make ~sender ~recipients "example_thanks" in
    let received = Rules.Collection.lucky thanks [] ~dice in

    print_luck thanks;
    [%expect
      {|
          example_sender1 -> 20
          example_recipient1 -> 20
          example_recipient2 -> 20 |}];

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_recipient1"; name = "player"; tz_offset = 0;
          items = [("🍀", 1)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🎁", 1); about = "luck bonus"; cooldown = None }
      ---
      { player =
        { id = "example_recipient2"; name = "player"; tz_offset = 0;
          items = [("🍀", 1)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🎁", 1); about = "luck bonus"; cooldown = None }
      --- |}]

  let%expect_test "🎁x1 -> recipients when luck is 40 and dice rolls 39" =
    let items = [ ("🍀", 2) ] in
    let sender = Player.make ~items "example_sender1"
    and recipient1 = Player.make ~items "example_recipient1"
    and recipient2 = Player.make ~items "example_recipient2" in
    let recipients = [ recipient1; recipient2 ] in

    let dice _ = 39 in
    print_int (dice 100);
    [%expect {| 39 |}];

    let thanks = Thanks.make ~sender ~recipients "example_thanks" in
    let received = Rules.Collection.lucky thanks [] ~dice in

    print_luck thanks;
    [%expect
      {|
          example_sender1 -> 40
          example_recipient1 -> 40
          example_recipient2 -> 40 |}];

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_recipient1"; name = "player"; tz_offset = 0;
          items = [("🍀", 2)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🎁", 1); about = "luck bonus"; cooldown = None }
      ---
      { player =
        { id = "example_recipient2"; name = "player"; tz_offset = 0;
          items = [("🍀", 2)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🎁", 1); about = "luck bonus"; cooldown = None }
      --- |}]

  let%expect_test "🎁x1 -> recipients when luck is 60 and dice rolls 59" =
    let items = [ ("🍀", 3) ] in
    let sender = Player.make ~items "example_sender1"
    and recipient1 = Player.make ~items "example_recipient1"
    and recipient2 = Player.make ~items "example_recipient2" in
    let recipients = [ recipient1; recipient2 ] in

    let dice _ = 59 in
    print_int (dice 100);
    [%expect {| 59 |}];

    let thanks = Thanks.make ~sender ~recipients "example_thanks" in
    let received = Rules.Collection.lucky thanks [] ~dice in

    print_luck thanks;
    [%expect
      {|
          example_sender1 -> 60
          example_recipient1 -> 60
          example_recipient2 -> 60 |}];

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_recipient1"; name = "player"; tz_offset = 0;
          items = [("🍀", 3)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🎁", 1); about = "luck bonus"; cooldown = None }
      ---
      { player =
        { id = "example_recipient2"; name = "player"; tz_offset = 0;
          items = [("🍀", 3)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🎁", 1); about = "luck bonus"; cooldown = None }
      --- |}]

  let%expect_test "🎁x1 -> recipients when luck is 80 and dice rolls 79" =
    let items = [ ("🍀", 4) ] in
    let sender = Player.make ~items "example_sender1"
    and recipient1 = Player.make ~items "example_recipient1"
    and recipient2 = Player.make ~items "example_recipient2" in
    let recipients = [ recipient1; recipient2 ] in

    let dice _ = 79 in
    print_int (dice 100);
    [%expect {| 79 |}];

    let thanks = Thanks.make ~sender ~recipients "example_thanks" in
    let received = Rules.Collection.lucky thanks [] ~dice in

    print_luck thanks;
    [%expect
      {|
          example_sender1 -> 80
          example_recipient1 -> 80
          example_recipient2 -> 80 |}];

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_recipient1"; name = "player"; tz_offset = 0;
          items = [("🍀", 4)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🎁", 1); about = "luck bonus"; cooldown = None }
      ---
      { player =
        { id = "example_recipient2"; name = "player"; tz_offset = 0;
          items = [("🍀", 4)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🎁", 1); about = "luck bonus"; cooldown = None }
      --- |}]

  let%expect_test "🎁x1 -> recipients when luck is 100 and dice rolls 99" =
    let items = [ ("🍀", 5) ] in
    let sender = Player.make ~items "example_sender1"
    and recipient1 = Player.make ~items "example_recipient1"
    and recipient2 = Player.make ~items "example_recipient2" in
    let recipients = [ recipient1; recipient2 ] in

    let dice _ = 99 in
    print_int (dice 100);
    [%expect {| 99 |}];

    let thanks = Thanks.make ~sender ~recipients "example_thanks" in
    let received = Rules.Collection.lucky thanks [] ~dice in

    print_luck thanks;
    [%expect
      {|
          example_sender1 -> 100
          example_recipient1 -> 100
          example_recipient2 -> 100 |}];

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_recipient1"; name = "player"; tz_offset = 0;
          items = [("🍀", 5)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🎁", 1); about = "luck bonus"; cooldown = None }
      ---
      { player =
        { id = "example_recipient2"; name = "player"; tz_offset = 0;
          items = [("🍀", 5)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🎁", 1); about = "luck bonus"; cooldown = None }
      --- |}]
end

module Gift_box_test = struct
  let items = [ ("🎁", 1) ]
  let sender = Player.make ~items "example_sender1"
  let thanks = Thanks.make ~sender "example_thanks"

  let%expect_test "static dice 1" =
    let dice _ = 1 in
    let received = Rules.Collection.gift_box thanks [] ~dice in

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_sender1"; name = "player"; tz_offset = 0;
          items = [("🎁", 1)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🎁", -1); about = "opened"; cooldown = None }
      ---
      { player =
        { id = "example_sender1"; name = "player"; tz_offset = 0;
          items = [("🎁", 1)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🌮", 5); about = "bonus"; cooldown = None }
      --- |}]

  let%expect_test "static dice 2" =
    let dice _ = 2 in
    let received = Rules.Collection.gift_box thanks [] ~dice in

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_sender1"; name = "player"; tz_offset = 0;
          items = [("🎁", 1)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🎁", -1); about = "opened"; cooldown = None }
      ---
      { player =
        { id = "example_sender1"; name = "player"; tz_offset = 0;
          items = [("🎁", 1)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🍻", 5); about = "bonus"; cooldown = None }
      --- |}]

  let%expect_test "sequential dice" =
    let dice = Dice.dice_sequential () in
    let received = Rules.Collection.gift_box thanks [] ~dice in

    List.iter print_deposit received;

    [%expect
      {|
      { player =
        { id = "example_sender1"; name = "player"; tz_offset = 0;
          items = [("🎁", 1)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🎁", -1); about = "opened"; cooldown = None }
      ---
      { player =
        { id = "example_sender1"; name = "player"; tz_offset = 0;
          items = [("🎁", 1)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🍻", 1); about = "bonus"; cooldown = None }
      ---
      { player =
        { id = "example_sender1"; name = "player"; tz_offset = 0;
          items = [("🎁", 1)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("☕️", 1); about = "bonus"; cooldown = None }
      ---
      { player =
        { id = "example_sender1"; name = "player"; tz_offset = 0;
          items = [("🎁", 1)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🎃", 1); about = "bonus"; cooldown = None }
      ---
      { player =
        { id = "example_sender1"; name = "player"; tz_offset = 0;
          items = [("🎁", 1)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🌶️", 1); about = "bonus"; cooldown = None }
      ---
      { player =
        { id = "example_sender1"; name = "player"; tz_offset = 0;
          items = [("🎁", 1)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🔥", 1); about = "bonus"; cooldown = None }
      --- |}]
end

module ExchangeRules_test = struct
  let%expect_test "🌮 exchange" =
    let player1 = Player.make ~items:[ ("🌮", 49) ] "example_player1"
    and player2 = Player.make ~items:[ ("🌮", 50) ] "example_player2"
    and player3 = Player.make ~items:[ ("🌮", 60) ] "example_player3" in

    let players = [ player1; player2; player3 ] in
    let received = Rules.Exchange.exchange players in

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_player2"; name = "player"; tz_offset = 0;
          items = [("🌮", 50)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🌮", -50); about = "exchange"; cooldown = None }
      ---
      { player =
        { id = "example_player2"; name = "player"; tz_offset = 0;
          items = [("🌮", 50)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🔥", 1); about = "exchange"; cooldown = None }
      ---
      { player =
        { id = "example_player3"; name = "player"; tz_offset = 0;
          items = [("🌮", 60)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🌮", -50); about = "exchange"; cooldown = None }
      ---
      { player =
        { id = "example_player3"; name = "player"; tz_offset = 0;
          items = [("🌮", 60)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🔥", 1); about = "exchange"; cooldown = None }
      --- |}]

  let%expect_test "☕️ exchange" =
    let player1 = Player.make ~items:[ ("☕️", 24) ] "example_player1"
    and player2 = Player.make ~items:[ ("☕️", 25) ] "example_player2"
    and player3 = Player.make ~items:[ ("☕️", 30) ] "example_player3" in

    let players = [ player1; player2; player3 ] in
    let received = Rules.Exchange.exchange players in

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_player2"; name = "player"; tz_offset = 0;
          items = [("☕️", 25)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("☕", -25); about = "exchange"; cooldown = None }
      ---
      { player =
        { id = "example_player2"; name = "player"; tz_offset = 0;
          items = [("☕️", 25)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🔥", 1); about = "exchange"; cooldown = None }
      ---
      { player =
        { id = "example_player3"; name = "player"; tz_offset = 0;
          items = [("☕️", 30)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("☕", -25); about = "exchange"; cooldown = None }
      ---
      { player =
        { id = "example_player3"; name = "player"; tz_offset = 0;
          items = [("☕️", 30)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🔥", 1); about = "exchange"; cooldown = None }
      --- |}]

  let%expect_test "🌶️ exchange" =
    let player1 = Player.make ~items:[ ("🌶️", 9) ] "example_player1"
    and player2 = Player.make ~items:[ ("🌶️", 10) ] "example_player2"
    and player3 = Player.make ~items:[ ("🌶️", 15) ] "example_player3" in

    let players = [ player1; player2; player3 ] in
    let received = Rules.Exchange.exchange players in

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_player2"; name = "player"; tz_offset = 0;
          items = [("🌶️", 10)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🌶️", -10); about = "exchange"; cooldown = None }
      ---
      { player =
        { id = "example_player2"; name = "player"; tz_offset = 0;
          items = [("🌶️", 10)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🔥", 1); about = "exchange"; cooldown = None }
      ---
      { player =
        { id = "example_player3"; name = "player"; tz_offset = 0;
          items = [("🌶️", 15)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🌶️", -10); about = "exchange"; cooldown = None }
      ---
      { player =
        { id = "example_player3"; name = "player"; tz_offset = 0;
          items = [("🌶️", 15)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🔥", 1); about = "exchange"; cooldown = None }
      --- |}]

  let%expect_test "🍻 exchange" =
    let player1 = Player.make ~items:[ ("🍻", 24) ] "example_player1"
    and player2 = Player.make ~items:[ ("🍻", 25) ] "example_player2"
    and player3 = Player.make ~items:[ ("🍻", 30) ] "example_player3" in

    let players = [ player1; player2; player3 ] in
    let received = Rules.Exchange.exchange players in

    List.iter print_deposit received;
    [%expect
      {|
      { player =
        { id = "example_player2"; name = "player"; tz_offset = 0;
          items = [("🍻", 25)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🍻", -25); about = "exchange"; cooldown = None }
      ---
      { player =
        { id = "example_player2"; name = "player"; tz_offset = 0;
          items = [("🍻", 25)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🍀", 1); about = "exchange"; cooldown = None }
      ---
      { player =
        { id = "example_player3"; name = "player"; tz_offset = 0;
          items = [("🍻", 30)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🍻", -25); about = "exchange"; cooldown = None }
      ---
      { player =
        { id = "example_player3"; name = "player"; tz_offset = 0;
          items = [("🍻", 30)]; cooldowns = [];
          score = { base = 0; bonus = 0; total = 0 }; highscore = 0; luck = 0;
          is_bot = false };
        item = ("🍀", 1); about = "exchange"; cooldown = None }
      --- |}]
end

module Self_penalty_test = struct
  let sender = Player.make "example_sender1"
  let recipient1 = Player.make "example_recipient1"
  let recipient2 = Player.make "example_recipient2"

  let%expect_test "no 💀 when recipients dont include sender" =
    let recipients = [ recipient1; recipient2 ] in
    let thanks = Thanks.make ~sender ~recipients "example_thanks" in
    let received = Rules.Collection.self_penalty thanks [] in

    List.iter print_deposit received;

    [%expect {||}]

  let%expect_test "💀x1 -> sender when recipients include sender" =
    let recipients = [ recipient1; recipient2; sender ] in
    let thanks = Thanks.make ~sender ~recipients "example_thanks" in
    let received = Rules.Collection.self_penalty thanks [] in

    List.iter print_deposit received;

    [%expect
      {|
      { player =
        { id = "example_sender1"; name = "player"; tz_offset = 0; items = [];
          cooldowns = []; score = { base = 0; bonus = 0; total = 0 };
          highscore = 0; luck = 0; is_bot = false };
        item = ("💀", 1); about = "self-mention penalty"; cooldown = None }
      --- |}]
end

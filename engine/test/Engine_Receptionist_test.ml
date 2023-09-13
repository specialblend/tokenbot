open Tokenbot
open Engine

module Parse_mentions_test = struct
  let%expect_test "it parses expected ids" =
    let msg =
      Slack.AppMention.make ~text:"thanks <@player1> and <@player2>" ()
    in
    let mentions = Receptionist.parse_mentions (Slack.AppMention.text msg) in
    print_endline (String.concat "," mentions);
    [%expect {| player1,player2 |}]
end

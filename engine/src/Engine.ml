exception InvalidPayload of string
exception DroppedMsg of Msg.t * string

let drop msg reason = Error (DroppedMsg (msg, reason))

let check msg ~token ~db =
  let open Thanks in
  match Mentions.scan msg ~token ~db with
  | None -> drop msg "no recipients"
  | Some (me, sender, recipients) ->
      let everyone = me :: sender :: recipients in
      Ok
        {
          sender;
          recipients;
          text = Fmt.fmt_text everyone msg.text ~db;
          diffs = [];
          txns = [];
          msg;
        }

let receive payload ~token ~db =
  match Msg.parse payload with
  | Some msg when Msg.is_edited msg -> drop msg "message edited"
  | Some msg -> check msg ~token ~db
  | None -> Error (InvalidPayload payload)

let handle payload ~db ~token =
  let open Rules in
  let exec = Cashier.exec ~rules ~db ~token in
  match receive payload ~db ~token with
  | Ok msg -> exec msg
  | Error exn -> Error exn

let run payload ~token = Red.once_bind (handle payload ~token)

module Feed = Feed
module Player = Player
module Scoreboard = Scoreboard
module Thanks = Thanks
module User = User
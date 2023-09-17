open Contract
open Fun

module Engine : Engine = struct
  type 'a io

  module Item = Item
  module Msg = Slack.AppMention
  module Player = Player
  module Thanks = Thanks
  module Deposit = Deposit

  (*  *)
  module ThanksDB = ThanksDB
  module PlayerDB = PlayerDB

  type sender = Sender of Player.t
  type recipient = Recipient of Player.t

  (*  *)
  type received = Received of Msg.t
  type scanned = Scanned of received * sender * recipient list
  type collected = Collected of scanned * Deposit.t list
  type distributed = Distributed of collected * (Player.t * Item.t list) list
  type exchanged = Exchanged of distributed * Deposit.t list
  type settled = Settled of exchanged * distributed
  type published = Published of settled
  type notified = Notified of published

  let db : PlayerDB.t = assert false

  module Receptionist = struct
    let split_words = Str.split (Str.regexp " ")

    let parse_mention =
      function%pcre
      | {|(<@(?<user_id>\w+)>)|} -> Some user_id
      | _ -> None

    let parse_emoji =
      function%pcre
      | {|((?<shortcode>:\w+:))|} -> Token.from_shortcode shortcode
      | _ -> None

    let parse_mentions text =
      text
      |> split_words
      |> Lst.filter_map (fun word -> parse_mention word)
      |> Str.dedupe

    let parse_emojis text =
      text
      |> split_words
      |> Lst.filter_map (fun word -> parse_emoji word)
      |> Str.dedupe

    let _scan msg =
      let sender_id = Msg.user msg in
      let recipient_ids = msg |> Msg.text |> parse_mentions in
      let _sender = PlayerDB.get db sender_id
      and _recipients = Lst.map (PlayerDB.get db) recipient_ids
      and _tokens = msg |> Msg.text |> parse_emojis in
      ()
  end

  let run _ = assert false
end

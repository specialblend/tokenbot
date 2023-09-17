open Contract
open Fun

module Engine : Engine = struct
  type 'a io

  module Item = Item
  module Msg = Msg
  module Player = Player
  module Thanks = Thanks
  module Txn = Txn

  (*  *)
  module ThanksDB = ThanksDB
  module PlayerDB = PlayerDB
  module NotifierAPI = NotifierAPI

  type sender = Sender of Player.t
  type recipient = Recipient of Player.t

  (*  *)
  type received = Received of Msg.t
  type scanned = Scanned of received * sender * recipient list
  type collected = Collected of scanned * Txn.t list
  type distributed = Distributed of collected * (Player.t * Item.t list) list
  type exchanged = Exchanged of distributed * Txn.t list
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

    let scan msg =
      let sender_id = Msg.userid msg in
      let recipient_ids =
        msg |> Msg.text |> fun (Long str) -> str |> parse_mentions
      in
      let sender = PlayerDB.get db sender_id
      and recipients = Lst.map (PlayerDB.get db) recipient_ids in
      ()
  end

  let run _ = assert false
end

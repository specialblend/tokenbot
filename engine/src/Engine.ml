open Contract

module Receptionist = struct
  let _scan _msg = assert false
end

module Engine : Engine = struct
  type 'a io

  module Item = Item
  module Msg = Slack.Msg
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

  let _db = assert false
  let run _ = assert false
end

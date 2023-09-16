open Contract

module Engine : Engine = struct
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
  type received = Received of Msg.t
  type scanned = Scanned of received * sender * recipient list
  type collected = Collected of scanned * Txn.t list
  type distributed = Distributed of collected * (Player.t * Item.t list) list
  type exchanged = Exchanged of distributed * Txn.t list
  type settled = Settled of exchanged * distributed
  type published = Published of settled
  type notified = Notified of published

  let run _ = assert false
end

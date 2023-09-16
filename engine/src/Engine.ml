open Contract
open Fun

module Engine : Engine = struct
  module Thanks = Thanks
  module ThanksDB = ThanksDB
  module PlayerDB = PlayerDB
  module NotifierAPI = NotifierAPI

  type collector_rule = Thanks.t -> Thanks.Txn.t list -> Thanks.Txn.t list
  type exchange_rule = Thanks.Txn.Item.t -> Thanks.Txn.t list
  type sender = Sender of Thanks.Player.t
  type recipient = Recipient of Thanks.Player.t

  (*  *)
  type received = Received of Thanks.Msg.t * Thanks.t
  type collected = Collected of Thanks.Txn.t list
  type distributed = Distributed of Thanks.Player.t list
  type exchanged = Exchanged of Thanks.Player.t list
  type published = Published of Thanks.t
  type notified = Notified of Thanks.t

  (*  *)
  type receptionist = Thanks.Msg.t -> Thanks.t io
  type collector = collector_rule list -> Thanks.t -> collected
  type distributor = collected -> Thanks.t -> distributed
  type exchanger = exchange_rule list -> distributed -> Thanks.t -> exchanged
  type publisher = exchanged -> Thanks.t -> published io
  type notifier = published -> notified io

  (*  *)
  let receive _ = assert false
  let collect _ _ = assert false
  let exchange _ _ = assert false
  let distribute _ _ = assert false
  let publish _ = assert false
  let notify _ = assert false
  let engine = receive >> collect >> exchange >> distribute >> publish >> notify
end

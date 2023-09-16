open Contract

module Engine : ENGINE = struct
  type 'a io

  module Msg = Msg
  module Item = Item
  module Player = Player
  module Txn = Txn
  module Participant = Participant
  module Thanks = Thanks
  module ThanksDB = ThanksDB
  module PlayerDB = PlayerDB

  type collected = Collected of Txn.t list
  type distributed = Distributed of Participant.t list
  type exchanged = Exchanged of Participant.t list
  type published = Published of Thanks.t
  type notified = Notified of Thanks.t
  type collect_rule = Thanks.t -> Txn.t list -> Txn.t list
  type exchange_rule = Item.t -> Txn.t list

  let construct _ = assert false
  let collect _ _ = assert false
  let exchange _ _ = assert false
  let distribute _ _ = assert false
  let publish _ = assert false
  let notify _ = assert false
end

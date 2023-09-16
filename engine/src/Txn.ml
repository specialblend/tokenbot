open Contract

module Txn : TXN = struct
  module Participant = Participant
  module Item = Item
  module Cooldown = Cooldown

  type t = {
    item: Item.t;
    participant: Participant.t;
    cooldown: Cooldown.t option;
    about: short_text option;
  }
  [@@deriving fields]
end

include Txn

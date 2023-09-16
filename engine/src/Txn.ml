open Contract

module Txn : Txn = struct
  module Player = Player
  module Item = Item
  module Cooldown = Cooldown

  type t = {
    item: Item.t;
    player: Player.t;
    cooldown: Cooldown.t option;
    about: short_text option;
  }
  [@@deriving fields]
end

include Txn

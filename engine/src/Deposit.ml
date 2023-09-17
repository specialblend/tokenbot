open Contract

module Deposit : DEPOSIT = struct
  module Player = Player
  module Item = Item
  module Cooldown = Cooldown

  type t = {
    item: Item.t;
    player: Player.t;
    cooldown: Cooldown.t option;
    about: string option;
  }
  [@@deriving fields]
end

include Deposit

open Fun

module Player = struct
  type id = string [@@deriving yojson]

  module Item = Item
  module Cooldown = Cooldown

  type t = {
    id: id; [@main]
    name: id;
    base_score: int; [@default 0]
    bonus_score: int; [@default 0]
    luck: int; [@default 0]
    inventory: Item.t list; [@default []]
    cooldowns: Cooldown.t list; [@default []]
    is_bot: bool; [@default false]
  }
  [@@deriving fields, make, yojson]
end

module Summary = struct
  module Player = Player

  type id = Player.id [@@deriving yojson]

  type t = {
    id: id;
    name: string;
  }
  [@@deriving fields, yojson]

  let of_player Player.{ id; name } : t = { id; name }
end

include Player

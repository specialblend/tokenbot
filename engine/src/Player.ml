open Contract

module Player : PLAYER = struct
  type id = string

  module Item = Item
  module Cooldown = Cooldown

  type t = {
    id: id;
    name: string;
    base_score: int;
    bonus_score: int;
    luck: int;
    inventory: Item.t list;
    cooldowns: Cooldown.t list;
    is_bot: bool;
  }
  [@@deriving fields]

  let id { id; _ } = id
end

module Summary : PLAYER_SUMMARY = struct
  module Player = Player

  type t = {
    id: Player.id;
    name: string;
  }
  [@@deriving fields]

  let of_player { id; name } : t = { id; name }
end

include Player

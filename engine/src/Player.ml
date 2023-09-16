open Contract
open System

module Player : Player = struct
  type id

  module Item = Item
  module Cooldown = Cooldown

  type t = {
    id: id;
    name: short_text;
    base_score: Nat.t;
    bonus_score: Nat.t;
    luck: Nat.t;
    inventory: Item.t list;
    cooldowns: Cooldown.t list;
    is_bot: bool;
  }
  [@@deriving fields]
end

module Summary = struct
  type t = {
    id: Player.id;
    name: short_text;
  }
  [@@deriving fields]

  let of_player { id; name } : t = { id; name }
end

include Player

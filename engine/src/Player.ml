open Contract
open System

module Player : PLAYER = struct
  type id

  module Item = Item
  module Cooldown = Cooldown
  module Percentage = Percentage

  module Summary = struct
    type t = {
      id: id;
      name: short_text;
    }
    [@@deriving fields]
  end

  type summary = Summary.t

  module Nat = Nat

  type t = {
    id: id;
    name: short_text;
    base_score: Nat.t;
    bonus_score: Nat.t;
    luck: Percentage.t;
    inventory: Item.t list;
    cooldowns: Cooldown.t list;
    is_bot: bool;
  }
  [@@deriving fields]

  let summary { id; name } : Summary.t = { id; name }
end

include Player

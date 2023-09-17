open Contract

module Player : PLAYER = struct
  type id = string

  module Item = Item
  module Cooldown = Cooldown

  type t = {
    id: id;
    name: id;
    base_score: int;
    bonus_score: int;
    luck: int;
    inventory: Item.t list;
    cooldowns: Cooldown.t list;
    is_bot: bool;
  }
  [@@deriving fields]
end

module Summary : PLAYER_SUMMARY = struct
  module Player = Player

  type id = Player.id

  type t = {
    id: id;
    name: string;
  }
  [@@deriving fields]

  (* TODO use destructure syntax *)
  let of_player (_p : Player.t) : t = assert false
end

include Player

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

  let id { id; _ } = id
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
  let of_player (p : Player.t) : t = { id = Player.id p; name = Player.name p }
end

include Player

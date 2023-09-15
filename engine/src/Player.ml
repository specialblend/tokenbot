open Contract

module Player : PLAYER = struct
  type id
  type item
  type cooldown

  module Summary = struct
    type t = {
      id: id;
      name: short_text;
    }
    [@@deriving fields]
  end

  type summary = Summary.t

  type t = {
    id: id;
    name: short_text;
    base_score: nat;
    bonus_score: nat;
    luck: stat;
    inventory: item list;
    cooldowns: cooldown list;
    is_bot: bool;
  }
  [@@deriving fields]

  let summary { id; name } : Summary.t = { id; name }
end

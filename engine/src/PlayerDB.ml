open Contract

module PlayerDB : PLAYER_DB = struct
  type t
  type 'a io

  module Player = Player

  let get _db (_id : Player.id) = assert false
  let put _db (_p : Player.t) = assert false
end

include PlayerDB

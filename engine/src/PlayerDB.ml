open Contract

module PlayerDB : PlayerDB = struct
  type t

  module Player = Player

  let get_player _db _id = assert false
  let put_player _db _player = assert false
end

include PlayerDB

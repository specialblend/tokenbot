module PlayerDB = struct
  type t
  type 'a io

  module Player = Player

  let get _db _id = assert false
  let put _db _player = assert false
end

include PlayerDB

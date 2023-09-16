open Contract

module ThanksDB : ThanksDB = struct
  type 'a io
  type t

  module Thanks = Thanks

  let get_thanks _db _id = assert false
  let put_thanks _db _thx = assert false
end

include ThanksDB

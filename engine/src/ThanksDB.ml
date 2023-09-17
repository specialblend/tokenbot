open Contract

module ThanksDB : THANKS_DB = struct
  type t
  type 'a io = 'a Lwt.t

  module Thanks = Thanks

  let get _db _id = assert false
  let put _db _thx = assert false
end

include ThanksDB

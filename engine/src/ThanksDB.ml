module ThanksDB = struct
  module Thanks = Thanks

  type t
  type 'a io = 'a Lwt.t

  let get _db _id = assert false
  let put _db _thx = assert false
end

include ThanksDB

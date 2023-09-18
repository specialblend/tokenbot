open Contract

module Duration = struct
  type t = duration

  let ( + ) _x _y = assert false
end

module Cooldown = struct
  type t = token * duration

  let token (_tok, _) = assert false
  let duration (_, _dur) = assert false
  let stack _items (_token, _duration) = assert false
end

include Cooldown

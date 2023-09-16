open Contract

module Cooldown : Cooldown = struct
  type t = token * duration

  let token (tok, _) = tok
  let duration (_, dur) = dur
end

include Cooldown

open Contract

module Cooldown : COOLDOWN = struct
  module Token = Token
  module Duration = System.Duration

  type t = Token.t * Duration.t

  let token (tok, _) = tok
  let duration (_, dur) = dur
end

include Cooldown

open Contract

module Cooldown : COOLDOWN = struct
  module Token = Token
  module Duration = System.Duration

  type t = Token.t * Duration.t

  let token (tok, _) = tok
  let duration (_, dur) = dur

  (* let normalize = function
       | n when n < 60 -> (n, `Seconds)
       | n when n < 3600 -> (n / 60, `Minutes)
       | n -> (n / 3600, `Hours)

     let describe = function
       | 1, `Seconds -> Fmt.sprintf "%d+ second" 1
       | n, `Seconds -> Fmt.sprintf "~%d seconds" n
       | 1, `Minutes -> Fmt.sprintf "%d+ minute" 1
       | n, `Minutes -> Fmt.sprintf "~%d minutes" n
       | 1, `Hours -> Fmt.sprintf "%d+ hour" 1
       | n, `Hours -> Fmt.sprintf "~%d hours" n

     let format = normalize >> describe

     let describe (token, cooldown) =
       Fmt.sprintf "cooldown warning for %s (%s)" token (format cooldown)

     let pp fmt (token, duration) =
       Format.fprintf fmt "(\"%s\", %d)" token duration *)
end

include Cooldown

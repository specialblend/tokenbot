open Fun

module Cooldown = struct
  type token = Item.token [@@deriving yojson]
  type seconds = int [@@deriving yojson]
  type t = token * seconds [@@deriving yojson]

  type duration =
    | Seconds of int
    | Minutes of int
    | Hours of int

  let token (token, _) = token
  let duration (_, seconds) = seconds

  let make token duration =
    match duration with
    | Seconds s -> (token, s)
    | Minutes m -> (token, m * 60)
    | Hours h -> (token, h * 60 * 60)

  let stack cooldowns ((token, seconds) as item) =
    match List.assoc_opt token cooldowns with
    | None -> item :: cooldowns
    | Some secs -> (token, seconds + secs) :: List.remove_assoc token cooldowns
end

include Cooldown

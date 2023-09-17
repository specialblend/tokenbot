open Contract

module Duration = struct
  type t = duration

  let ( + ) x y =
    match (x, y) with
    | Seconds x, Seconds y -> Seconds (x + y)
    | Minutes x, Minutes y -> Minutes (x + y)
    | Hours x, Hours y -> Hours (x + y)
    | Seconds x, Minutes y -> Minutes ((x / 60) + y)
    | Seconds x, Hours y -> Hours ((x / 3600) + y)
    | Minutes x, Seconds y -> Minutes (x + (y / 60))
    | Minutes x, Hours y -> Hours ((x / 60) + y)
    | Hours x, Seconds y -> Hours (x + (y / 3600))
    | Hours x, Minutes y -> Hours (x + (y / 60))
end

module Cooldown : COOLDOWN = struct
  type t = token * duration

  let token (tok, _) = tok
  let duration (_, dur) = dur

  let stack items (token, duration) =
    let duration =
      match List.assoc_opt token items with
      | Some duration' -> Duration.(duration + duration')
      | None -> duration
    in
    (token, duration) :: List.remove_assoc token items
end

include Cooldown

open Contract

module Cooldown = struct
  type t = token * duration

  let token (tok, _) = tok
  let duration (_, dur) = dur

  let make token duration =
    match duration with
    | Seconds s -> (token, s)
    | Minutes m -> (token, m * 60)
    | Hours h -> (token, h * 60 * 60)

  let stack items ((token, duration) as item) =
    match List.assoc_opt token items with
    | None -> item :: items
    | Some duration' ->
        (token, duration + duration') :: List.remove_assoc token items
end

include Cooldown

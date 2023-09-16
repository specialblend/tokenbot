open Contract
open System

module Duration = struct
  type t = duration

  let ( + ) (Seconds n1) (Seconds n2) = Seconds Nat.(n1 + n2)
end

module Cooldown : Cooldown = struct
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

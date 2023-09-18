open Contract

module Qty = struct
  type t = qty

  let ( + ) (Qty q1) (Qty q2) = Qty (q1 + q2)
end

module Item = struct
  type t = token * qty

  let token (Token emoji, _) = Token emoji
  let qty (_, q) = q

  (*  *)
  let make token qty = (token, qty)
  let map_qty fn (token, Qty q) = (token, Qty (fn q))

  let stack items item =
    let token, qty = item in
    match List.assoc_opt token items with
    | None -> item :: items
    | Some qty' -> (token, Qty.(qty + qty')) :: List.remove_assoc token items
end

include Item

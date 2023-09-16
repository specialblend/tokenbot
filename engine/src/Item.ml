open Fun
open Contract
open System

module Qty = struct
  type t = qty

  let ( + ) (Qty q1) (Qty q2) = Qty Nat.(q1 + q2)
end

module Item : Item = struct
  type t = token * qty

  let token (tok, _) = tok
  let qty (_, q) = q

  (*  *)
  let make token qty = (token, qty)
  let map_qty fn (token, qty) = (token, fn qty)

  let stack items (token, qty) =
    let qty =
      match List.assoc_opt token items with
      | Some qty' -> Qty.(qty + qty')
      | None -> qty
    in
    (token, qty) :: List.remove_assoc token items
end

include Item

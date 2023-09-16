open Fun
open Contract
open System

module Item : Item = struct
  type t = token * qty

  let token (tok, _) = tok
  let qty (_, q) = q

  (*  *)
  let make token qty = (token, qty)
  let map_qty fn (token, qty) = (token, fn qty)

  (*  *)
  let stack items (token, Qty qty) =
    let qty =
      match List.assoc_opt token items with
      | Some (Qty qty') -> Nat.(qty + qty')
      | None -> qty
    in
    (token, Qty qty) :: List.remove_assoc token items
end

include Item

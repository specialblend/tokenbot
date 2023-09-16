open Fun
open Contract

module Item : ITEM = struct
  type token = Token.t
  type qty = int
  type t = token * qty

  let token (tok, _) = tok
  let qty (_, q) = q

  (*  *)
  let make token qty = (token, qty)
  let map_qty fn (token, qty) = (token, fn qty)

  (*  *)
  let stack items (token, qty) =
    let qty =
      match List.assoc_opt token items with
      | Some qty' -> qty + qty'
      | None -> qty
    in
    (token, qty) :: List.remove_assoc token items
end

include Item

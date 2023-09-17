open Contract

module Qty = struct
  type t = qty

  let ( + ) (Qty _q1) (Qty _q2) = assert false
end

module Item : ITEM = struct
  type t = token * qty

  let token (_tok, _) = assert false
  let qty (_, _q) = assert false

  (*  *)
  let make _token _qty = assert false
  let map_qty _fn (_token, _qty) = assert false
  let stack _items (_token, _qty) = assert false
end

include Item

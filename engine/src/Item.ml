open Fun

module Item = struct
  type token = Token of string [@@deriving yojson]
  type qty = int [@@deriving yojson]
  type t = token * qty [@@deriving yojson]

  let token (tok, _) = tok
  let qty (_, q) = q
  let make token qty = (token, qty)
  let map_qty fn (token, q) = (token, fn q)

  let stack items item =
    let token, qty = item in
    match List.assoc_opt token items with
    | None -> item :: items
    | Some qty' -> (token, qty + qty') :: List.remove_assoc token items
end

include Item

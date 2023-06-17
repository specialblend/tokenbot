open Fun

module Item = struct
  type t = string * int [@@deriving show, yojson]
end

type t = Item.t list [@@deriving show, yojson]

let int = int_of_string_opt
let scope = Red.prefix "inventory"

let exec deposit ~db =
  let player, item = Deposit.part deposit in
  let token, qty = item in
  let key = scope player in
  Red.hincrby db key token qty

let has_qty (_, qty) = qty > 0

let scan player ~db =
  let key = scope player in
  let pairs = Red.hgetall db key
  and from (token, qty) =
    let qty' = default 0 (int qty) in
    (token, qty')
  in
  let items = List.map from pairs in
  List.filter has_qty items

let get_qty player token ~db =
  let key = scope player in
  let qty = Red.hget db key token in
  let qty' = (Option.flat_map int) qty in
  default 0 qty'
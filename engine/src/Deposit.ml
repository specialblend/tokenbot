type t = {
  target: string;
  about: string;
  token: string;
  qty: int;
  cooldown: int option; [@yojson.option]
}
[@@deriving fields, show, yojson]

let item_of { token; qty } = (token, qty)
let part t = (t.target, item_of t)

let give ?(qty = 1) ?cooldown target token about =
  { target; token; qty; about; cooldown }

let token_eq token t = t.token = token
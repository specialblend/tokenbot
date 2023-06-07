open Fun

type t = {
  bonus: int; [@yojson.default 0]
  greed: int; [@yojson.default 0]
  luck: int; [@yojson.default 0]
}
[@@deriving fields, show, yojson]

let clamp = Math.clamp (0, 100)

let clamp_all s =
  { greed = clamp s.greed; luck = clamp s.luck; bonus = clamp s.bonus }

let calc items =
  let stats = { bonus = 0; greed = 0; luck = 0 } in
  let into stats item =
    let open Tokens in
    let token, qty = item in
    let effects = fx token in
    let into stats = function
      | Greed amt -> { stats with greed = stats.greed + (amt * qty) }
      | Luck amt -> { stats with luck = stats.luck + (amt * qty) }
      | Bonus amt -> { stats with bonus = stats.bonus + (amt * qty) }
    in
    List.fold effects into stats
  in
  clamp_all (List.fold items into stats)

let scope = Red.prefix "stats"

let put player stat value ~db =
  let key = scope player in
  Red.hset db key stat (string_of_int value)

let get player stat ~db =
  let key = scope player in
  Red.hget db key stat ->. Option.flat_map int_of_string_opt ->. default 0

let get_bonus player ~db = get player "bonus" ~db
let get_luck player ~db = get player "luck" ~db
let get_greed player ~db = get player "greed" ~db

let publish player stats ~db =
  let { bonus; greed; luck } = stats in
  let set = put player ~db in
  void (set "bonus" bonus, set "greed" greed, set "luck" luck)
open Fun

type t = Player.t list [@@deriving show, yojson]

let to_string = Json.stringify ~yojson_of_t

let keep_strings =
  List.filter_map (function
    | `Bulk (Some str) -> Some str
    | _ -> None)

module DB = struct
  let scan key count ~db =
    let limit = (0, count) in
    let range = Red.zrevrangebyscore db ~limit key in
    let replies = range PosInfinity (Inclusive 1.) in
    let players = keep_strings replies in
    List.map (Player.DB.scan ~db) players
end
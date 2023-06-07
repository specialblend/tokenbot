open Fun

type t = Thanks.t list [@@deriving show, yojson]

let to_string = Json.stringify ~yojson_of_t
let scan_any count ~db = Thanks.DB.scan "thanks" count ~db
let scan_about player count ~db = Thanks.DB.scan_about player count ~db
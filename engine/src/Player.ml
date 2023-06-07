open Fun

type t = {
  id: string;
  score: int;
  highscore: int;
  inventory: Inventory.t;
  stats: Stats.t;
}
[@@deriving show, yojson]

let to_string = Json.stringify ~yojson_of_t

module Players = struct
  type l = t list [@@deriving show, yojson]
  type t = l [@@deriving show, yojson]

  let to_string = Json.stringify ~yojson_of_t
end

let time thx player ~db =
  let offset = User.DB.get_tz_offset player ~db in
  Msg.tm Thanks.(thx.msg) ?offset

module DB = struct
  let scan id ~db =
    let inventory = Inventory.scan id ~db in
    let stats = Stats.calc inventory in
    let score = Score.calc stats inventory in
    let highscore = Score.get_highscore id score ~db in
    { id; score; highscore; inventory; stats }

  let search q ~count ~db =
    User.DB.search q ~count ~db
    ->. List.reject (User.DB.get_is_bot ~db)
    ->. List.map (scan ~db)

  let publish player ~db =
    let { id; stats; score; highscore } = player in

    Stats.publish id stats ~db;
    Score.publish id score highscore ~db;

    let key = Red.prefix "player" id
    and value = to_string player in

    void (Red.set db key value);
    player

  let scan_publish id ~db =
    let player = scan id ~db in
    publish player ~db
end
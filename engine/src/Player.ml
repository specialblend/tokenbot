open Fun

module Score = struct
  type t = {
    base: int; [@default 0]
    bonus: int; [@default 0]
    total: int; [@default 0]
  }
  [@@deriving ord, fields, make, show { with_path = false }, yojson]

  let sum = Lst.fold_left ( + ) 0
  let stack1 fn (token, qty) = fn token * qty
  let stack fn = Lst.map (stack1 fn)
  let points = stack Token.points >> sum >> max 0
  let bonus = stack Token.bonus >> sum >> clamp (0, 100)
  let luck = stack Token.luck >> sum >> clamp (0, 100)

  let score items =
    let base = points items in
    let bonus = base * bonus items / 100 in
    let total = base + bonus in
    { base; bonus; total }
end

module Player = struct
  type t = {
    id: string; [@main]
    name: string; [@default "player"]
    tz_offset: int; [@default 0]
    items: Item.t list; [@default []]
    cooldowns: Item.Cooldown.t list; [@default []]
    score: Score.t; [@default Score.make ()]
    highscore: int; [@default 0]
    luck: int; [@default 0]
    is_bot: bool; [@default false]
  }
  [@@deriving ord, fields, make, show { with_path = false }, yojson]

  let of_slack_user Slack.User.{ id; name; tz_offset; is_bot } =
    make id ~name ~tz_offset ~is_bot

  (**)
  let id_eq id player = player.id = id
  let is player t = id_eq t.id player

  (**)
  let cooldown token t = Lst.assoc_opt token t.cooldowns
  let luck t = Score.luck t.items
  let total_score = score >> Score.total

  let part_sender sender_id players =
    match Lst.partition (id_eq sender_id) players with
    | sender :: _, recipients -> Some (sender, recipients)
    | _ -> None

  (**)
  let with_cooldowns fn t = { t with cooldowns = fn t.cooldowns }
  let with_items fn t = { t with items = fn t.items }

  (**)
  let recalculate t =
    let score = Score.score t.items
    and luck = Score.luck t.items in
    let highscore = max t.highscore score.total in
    { t with score; highscore; luck }

  module Summary = struct
    type t = {
      id: string;
      name: string;
    }
    [@@deriving ord, show { with_path = false }, yojson]
  end

  let summary { id; name } = { Summary.id; name }
end

include Player
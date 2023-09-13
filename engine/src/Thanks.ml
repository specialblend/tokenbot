open Fun
open Format

module Deposit = struct
  let fmt_about fmt = fprintf fmt "\"%s\""

  type t = {
    player: Player.t;
    item: Item.t;
    about: string; [@default "thanks"] [@printer fmt_about]
    cooldown: int option; [@default None]
  }
  [@@deriving fields, make, show { with_path = false }, yojson]

  let give ?(qty = 1) ?about ?cooldown player token =
    let item = (token, qty) in
    let about =
      match (about, Token.about token) with
      | Some about, _ -> about
      | _, about -> about
    in
    { player; item; about; cooldown }

  let belongs_to target { player } = Player.is target player
  let token_eq token t = fst t.item = token

  let token_cooldown = function
    | { item = token, _; cooldown = Some c } -> Some (token, c)
    | _ -> None

  module Summary = struct
    type t = {
      player: Player.Summary.t;
      item: Item.t;
      about: string; [@printer fmt_about]
      cooldown: int option; [@default None]
    }
    [@@deriving fields, show, yojson]
  end

  let summary { player; item; about; cooldown } =
    { Summary.player = Player.summary player; item; about; cooldown }
end

module Thanks = struct
  type t = {
    id: string; [@main]
    msg: Slack.AppMention.t; [@default Slack.AppMention.make ()]
    sender: Player.t; [@default Player.make "example_sender"]
    recipients: Player.t list; [@default [ Player.make "example_recipient" ]]
    tokens: string list; [@default []]
    deposits: Deposit.t list; [@default []]
  }
  [@@deriving fields, make, show { with_path = false }, yojson]

  let update_parts t (sender, recipients) = { t with sender; recipients }
  let parts { sender; recipients } = (sender, recipients)
  let everyone { sender; recipients } = sender :: recipients

  let local_time t player =
    let ts = float_of_string t.msg.ts
    and offset = Player.tz_offset player in
    Unix.gmtime (ts +. float_of_int offset)

  module Summary = struct
    type t = {
      id: string;
      msg: Slack.AppMention.t;
      sender: Player.Summary.t;
      player_deposits: (Player.Summary.t * Deposit.Summary.t list) list;
      tokens: string list;
    }
    [@@deriving yojson]
  end

  let summary { id; msg; sender; tokens; deposits } =
    {
      Summary.id;
      msg;
      sender = Player.summary sender;
      tokens;
      player_deposits =
        deposits
        |> Lst.map Deposit.summary
        |> Lst.group_by Deposit.Summary.player;
    }
end

include Thanks
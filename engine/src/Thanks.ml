open Fun

module Txn = struct
  type t = string * Deposit.t list [@@deriving show, yojson]

  let belongs_to player (player_id, _) = player = player_id
end

type t = {
  text: string;
  sender: string;
  recipients: string list;
  msg: Msg.t;
  txns: Txn.t list;
  diffs: (string * int) list;
}
[@@deriving show, yojson]

let sender t = t.sender
let recipients t = t.recipients
let parts t = (sender t, recipients t)
let everyone t = sender t :: recipients t
let with_txns fn t = { t with txns = fn t.txns }
let from_json = Json.parse ~t_of_yojson
let keep_txns_about player = with_txns (List.filter (Txn.belongs_to player))

module DB = struct
  let scope = Red.prefix "thanks"
  let scope_about = Red.prefix "about" ->: scope
  let mark_about id player ~db = Red.lpush db (scope_about player) [ id ]

  let publish thanks ~db =
    let id = thanks.msg.client_msg_id in

    let key = scope id
    and value = Json.to_string (yojson_of_t thanks)
    and players = thanks ->. everyone in

    void (Red.set db key value);
    void (Red.lpush db "thanks" [ id ]);

    List.map_ignore (mark_about id ~db) players

  let scan key count ~db =
    match Red.lrange db key 0 (count - 1) with
    | [] -> []
    | ids ->
        ids
        ->. List.map scope
        ->. Red.mget db
        ->. List.filter_map (Option.map from_json)

  let scan_about player count ~db =
    let key = scope_about player in
    let thanks = scan key count ~db in
    List.map (keep_txns_about player) thanks
end

module Fmt = struct
  let group_regex =
    Str.regexp {|<!subteam\^\([A-Za-z0-9]+\)|@\([A-Za-z0-9 ]+\)>|}

  let fmt_users mentions text ~db =
    let open Format in
    let into text mention =
      let name = User.DB.get_name mention ~db ->. default "" in
      let search = Str.regexp_string (sprintf "<@%s>" mention)
      and repl = sprintf "@%s" name in
      Str.global_replace search repl text
    in
    List.fold mentions into text

  let fmt_shortcodes text =
    let into text (shortcode, emoji) =
      let regex = Str.regexp shortcode in
      Str.global_replace regex emoji text
    in
    List.fold Tokens.shortcodes into text

  let fmt_groups = Str.global_replace group_regex {|@\2|}

  let fmt_text mentions text ~db =
    let text' = fmt_users mentions text ~db in
    fmt_shortcodes (fmt_groups text')
end
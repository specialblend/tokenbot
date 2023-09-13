open Fun
open Fun.Let_syntax

(**)
module Red = Redis_sync.Client
module Deposit = Thanks.Deposit
module Cooldown = Item.Cooldown

(* TODO build module type for this so it can be mocked *)
module DB = struct
  module J = Yojson.Safe

  let mget ~db =
    let mget = trap (Red.mget db) in
    function
    | [] -> Ok []
    | keys -> mget keys

  let scan ~count ~db =
    trap (fun pattern ->
        let rec scan_rec acc ~cursor =
          match Red.scan db cursor ~pattern ~count with
          | 0, [] -> acc
          | 0, keys -> acc @ keys
          | cursor, keys -> scan_rec (acc @ keys) ~cursor
        in
        scan_rec [] ~cursor:0)

  let scan_cooldowns player ~db =
    let parse_cooldown = Jsn.parse_opt Cooldown.t_of_yojson in
    player
    |> Player.id
    |> fmt "cooldown:%s:*"
    |> scan ~count:32 ~db
    |> Res.flat_map (mget ~db)
    |> Res.map (List.filter_map (Opt.flat_map parse_cooldown))

  let set_cooldowns Player.{ id; cooldowns } ~db =
    let setex = trap3 (Red.setex db) in
    let set cooldown =
      let token, ttl = cooldown in
      let key = fmt "cooldown:%s:%s" id token in
      cooldown
      |> Jsn.stringify Cooldown.yojson_of_t
      |> Res.flat_map (setex key ttl)
    in
    Res.all (List.map set cooldowns)

  let with_scan_cooldowns player ~db =
    let*! c = scan_cooldowns player ~db in
    Player.{ player with cooldowns = c }

  let get_player id ~db =
    let get = trap (Red.get db) in
    let parse = function
      | None -> Ok None
      | Some data ->
          data
          |> Jsn.parse Player.t_of_yojson
          |> Res.flat_map (with_scan_cooldowns ~db)
          |> Res.map (fun player -> Some player)
    in
    fmt "player:%s" id |> get |> Res.flat_map parse

  let fetch_player id ~token =
    let@! user = Slack.UserInfo.get id ~token in
    Player.of_slack_user user

  let set_player player ~db =
    let set = trap2 (Red.set db) in
    let key = fmt "player:%s" (Player.id player) in
    player
    |> Jsn.stringify Player.yojson_of_t
    |> Res.flat_map (set key)
    |> Res.map ignore
    |> Res.flat_map (fun () -> set_cooldowns player ~db)

  let lookup_player ~token ~db id =
    match get_player id ~db with
    | Ok (Some player) -> Lwt.return (Some player)
    | _ ->
        let@ res = fetch_player id ~token in
        let*? player = Res.to_option res in
        let _ = set_player player ~db in
        player

  let lpush_rotate key ~id ~db ~limit =
    let lpush = trap (Red.lpush db key)
    and ltrim = trap (Red.ltrim db key 0) in
    let trim = function
      | len when len >= limit -> ltrim len
      | _ -> Ok ()
    in
    lpush [ id ] |> Res.flat_map trim

  let lpush_thanks thx ~db =
    let id = Thanks.id thx in
    let push player =
      player
      |> Player.id
      |> fmt "thanks:@about:%s"
      |> lpush_rotate ~id ~limit:10 ~db
    in
    thx
    |> Thanks.everyone
    |> List.map push
    |> List.cons (lpush_rotate "thanks:@root" ~id ~limit:100 ~db)
    |> Res.all

  let set_thanks thx ~db =
    let set = trap2 (Red.set db) in
    let key = fmt "thanks:%s" (Thanks.id thx) in
    thx
    |> Thanks.summary
    |> Jsn.stringify Thanks.Summary.yojson_of_t
    |> Res.flat_map (set key)
    |> Res.map ignore

  let zadd_scores players ~db =
    let zadd = trap2 (Red.zadd db) in
    let map_score fn player =
      let id = Player.id player
      and score = fn player in
      (float_of_int score, id)
    in
    let scores = players |> List.map (map_score Player.total_score)
    and highscores = players |> List.map (map_score Player.highscore) in
    let*! _ = zadd "scores" scores
    and*! _ = zadd "highscores" highscores in
    ()

  let publish thx ~db =
    let players = Thanks.everyone thx in
    let*! () = lpush_thanks thx ~db
    and*! () = set_thanks thx ~db
    and*! () = zadd_scores players ~db
    and*! () = players |> List.map (set_player ~db) |> Res.all in
    ()
end

include DB
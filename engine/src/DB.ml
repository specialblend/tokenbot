open Fun
open Fun.Let_syntax
module Deposit = Thanks.Deposit
module Cooldown = Item.Cooldown

module DB = struct
  let scan_cooldowns player ~db =
    let parse_cooldowns list =
      let parse = Json.parse_opt Cooldown.t_of_yojson in
      List.filter_map
        (function
          | None -> None
          | Some cooldown -> parse cooldown)
        list
    in
    player
    |> Player.id
    |> Format.sprintf "cooldown:%s:*"
    |> Redis.scan_pattern db ~count:32
    |> Result.flat_map (Redis.mget_safe db)
    |> Result.map parse_cooldowns

  let set_cooldowns Player.{ id; cooldowns } ~db =
    let set cooldown =
      let token, ttl = cooldown in
      let key = Format.sprintf "cooldown:%s:%s" id token in
      cooldown
      |> Json.stringify Cooldown.yojson_of_t
      |> Result.flat_map (Redis.setex db key ttl)
    in
    Result.all (List.map set cooldowns)

  let get_player id ~db =
    let with_scan_cooldowns player ~db =
      let*! c = scan_cooldowns player ~db in
      Player.{ player with cooldowns = c }
    in
    let parse = function
      | None -> Ok None
      | Some data ->
          data
          |> Json.parse Player.t_of_yojson
          |> Result.flat_map (with_scan_cooldowns ~db)
          |> Result.map (fun player -> Some player)
    in
    id |> Format.sprintf "player:%s" |> Redis.get db |> Result.flat_map parse

  let fetch_player id ~token =
    let@! user = Slack.UserInfo.get id ~token in
    Player.of_slack_user user

  let set_player player ~db =
    let key = Format.sprintf "player:%s" (Player.id player) in
    player
    |> Json.stringify Player.yojson_of_t
    |> Result.flat_map (Redis.set db key)
    |> Result.map ignore
    |> Result.flat_map (fun () -> set_cooldowns player ~db)

  let lookup_player ~token ~db id =
    match get_player id ~db with
    | Ok (Some player) -> Lwt.return (Some player)
    | _ ->
        let@ res = fetch_player id ~token in
        res |> Result.to_option |> Option.map (Fun.tap (set_player ~db))

  let lpush_thanks thx ~db =
    let id = Thanks.id thx in
    let push player =
      player
      |> Player.id
      |> Format.sprintf "thanks:@about:%s"
      |> Redis.lpush_rotate ~id ~limit:10 ~db
    in
    thx
    |> Thanks.everyone
    |> List.map push
    |> List.cons (Redis.lpush_rotate "thanks:@root" ~id ~limit:100 ~db)
    |> Result.all

  let set_thanks thx ~db =
    let key = Format.sprintf "thanks:%s" (Thanks.id thx) in
    thx
    |> Thanks.summary
    |> Json.stringify Thanks.Summary.yojson_of_t
    |> Result.flat_map (Redis.set db key)
    |> Result.map ignore

  let zadd_scores players ~db =
    let map_score fn player =
      let id = Player.id player
      and score = fn player in
      (float_of_int score, id)
    in
    let*! () =
      players
      |> List.map (map_score Player.total_score)
      |> Redis.zadd db "scores"
      |> Result.map ignore
    and*! () =
      players
      |> List.map (map_score Player.highscore)
      |> Redis.zadd db "highscores"
      |> Result.map ignore
    in
    ()

  let publish thx ~db =
    let players = Thanks.everyone thx in
    let*! () = lpush_thanks thx ~db
    and*! () = set_thanks thx ~db
    and*! () = zadd_scores players ~db
    and*! () = players |> List.map (set_player ~db) |> Result.all in
    ()
end

include DB
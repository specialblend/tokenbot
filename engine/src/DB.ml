open Fun
open Fun.Let_syntax
module Red = Redis
module Deposit = Thanks.Deposit
module Cooldown = Item.Cooldown

module DB = struct
  let scan_cooldowns player ~db =
    let parse_cooldown =
      let parse = Jsn.parse_opt Cooldown.t_of_yojson in
      Option.flat_map (fun json -> parse json)
    in
    match
      player
      |> Player.id
      |> Fmt.sprintf "cooldown:%s:*"
      |> Red.scan_pattern db ~count:32
      |> Result.flat_map (Red.mget_safe db)
      |> Result.map (List.filter_map parse_cooldown)
    with
    | Ok cooldowns -> { player with cooldowns }
    | _ -> player

  let set_cooldowns Player.{ id; cooldowns } ~db =
    let set cooldown =
      let token, ttl = cooldown in
      let key = Fmt.sprintf "cooldown:%s:%s" id token in
      cooldown
      |> Jsn.stringify Cooldown.yojson_of_t
      |> Result.flat_map (Red.setex db key ttl)
    in
    Result.all (List.map set cooldowns)

  let get_player id ~db =
    let parse = function
      | None -> Ok None
      | Some data ->
          data
          |> Jsn.parse Player.t_of_yojson
          |> Result.map (fun player -> scan_cooldowns player ~db)
          |> Result.map (fun player -> Some player)
    in
    Fmt.sprintf "player:%s" id
    |> Red.get db
    |> Result.flat_map (fun json -> parse json)

  let fetch_player id ~token =
    let@! user = Slack.UserInfo.get id ~token in
    Player.of_slack_user user

  let set_player player ~db =
    let key = Fmt.sprintf "player:%s" (Player.id player) in
    player
    |> Jsn.stringify Player.yojson_of_t
    |> Result.flat_map (fun json -> Red.set db key json)
    |> Result.flat_map (fun _ -> set_cooldowns player ~db)

  let lookup_player ~token ~db id =
    match get_player id ~db with
    | Ok (Some player) -> Lwt.return (Some player)
    | _ ->
        let@ res = fetch_player id ~token in
        res
        |> Result.to_option
        |> Option.map (fun player -> set_player ~db |> always player)

  let lpush_thanks thx ~db =
    let id = Thanks.id thx in
    let push player =
      player
      |> Player.id
      |> Fmt.sprintf "thanks:@about:%s"
      |> Red.lpush_rotate ~id ~limit:10 ~db
    in
    thx
    |> Thanks.everyone
    |> List.map push
    |> List.cons (Red.lpush_rotate "thanks:@root" ~id ~limit:100 ~db)
    |> Result.all

  let set_thanks thx ~db =
    let key = Fmt.sprintf "thanks:%s" (Thanks.id thx) in
    thx
    |> Thanks.summary
    |> Jsn.stringify Thanks.Summary.yojson_of_t
    |> Result.flat_map (Red.set db key)
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
      |> Red.zadd db "scores"
      |> Result.map ignore
    and*! () =
      players
      |> List.map (map_score Player.highscore)
      |> Red.zadd db "highscores"
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

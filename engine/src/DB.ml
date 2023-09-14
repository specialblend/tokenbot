open Fun
open Fun.Let_syntax
module Red = Redis
module Deposit = Thanks.Deposit
module Cooldown = Item.Cooldown

module DB = struct
  let scan_cooldowns player ~db =
    let parse =
      let parse1 = Jsn.parse_opt Cooldown.t_of_yojson in
      Lst.filter_map (function
        | None -> None
        | Some cooldown -> parse1 cooldown)
    in
    player
    |> Player.id
    |> Fmt.sprintf "cooldown:%s:*"
    |> Red.scan_pattern db ~count:32
    |> Res.flat_map (fun key -> Red.mget_safe db key)
    |> Res.map (fun cooldowns -> parse cooldowns)
    |> function
    | Ok cooldowns -> { player with cooldowns }
    | _ -> player

  let set_cooldowns Player.{ id; cooldowns } ~db =
    let set cooldown =
      let token, ttl = cooldown in
      let key = Fmt.sprintf "cooldown:%s:%s" id token in
      cooldown
      |> Jsn.stringify Cooldown.yojson_of_t
      |> Res.flat_map (fun json -> Red.setex db key ttl json)
    in
    Res.all (Lst.map set cooldowns)

  let get_player id ~db =
    let parse = function
      | None -> Ok None
      | Some data ->
          data
          |> Jsn.parse Player.t_of_yojson
          |> Res.map (fun player -> scan_cooldowns player ~db)
          |> Res.map (fun player -> Some player)
    in
    Fmt.sprintf "player:%s" id
    |> Red.get db
    |> Res.flat_map (fun json -> parse json)

  let fetch_player id ~token =
    let@! user = Slack.UserInfo.get id ~token in
    Player.of_slack_user user

  let set_player player ~db =
    let key = Fmt.sprintf "player:%s" (Player.id player) in
    player
    |> Jsn.stringify Player.yojson_of_t
    |> Res.flat_map (fun json -> Red.set db key json)
    |> Res.flat_map (fun _ -> set_cooldowns player ~db)

  let lookup_player ~token ~db id =
    match get_player id ~db with
    | Ok (Some player) -> Lwt.return (Some player)
    | _ ->
        let@ res = fetch_player id ~token in
        res
        |> Res.to_option
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
    |> Lst.map push
    |> Lst.cons (Red.lpush_rotate "thanks:@root" ~id ~limit:100 ~db)
    |> Res.all

  let set_thanks thx ~db =
    let key = Fmt.sprintf "thanks:%s" (Thanks.id thx) in
    thx
    |> Thanks.summary
    |> Jsn.stringify Thanks.Summary.yojson_of_t
    |> Res.flat_map (Red.set db key)
    |> Res.map (fun res -> ignore res)

  let zadd_scores players ~db =
    let map_score fn player =
      let id = Player.id player
      and score = fn player in
      (float_of_int score, id)
    in
    let*! () =
      players
      |> Lst.map (map_score Player.total_score)
      |> Red.zadd db "scores"
      |> Res.map ignore
    and*! () =
      players
      |> Lst.map (map_score Player.highscore)
      |> Red.zadd db "highscores"
      |> Res.map ignore
    in
    ()

  let publish thx ~db =
    let players = Thanks.everyone thx in
    let*! () = lpush_thanks thx ~db
    and*! () = set_thanks thx ~db
    and*! () = zadd_scores players ~db
    and*! () = players |> Lst.map (set_player ~db) |> Res.all in
    ()
end

include DB
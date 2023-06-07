open Engine
open Fun

let msg () =
  let open Thanks in
  let token = Env.require_exn "SLACK_BOT_TOKEN" in
  match Engine.run (read_line ()) ~token with
  | Ok thanks -> bye (show thanks)
  | Error err -> die (fail err)

let feed count =
  let open Feed in
  match Red.once (scan_any count) with
  | Ok feed -> bye (to_string feed)
  | Error err -> die (fail err)

let feed_about player count =
  let open Feed in
  match Red.once (scan_about player count) with
  | Ok feed -> bye (to_string feed)
  | Error err -> die (fail err)

let scoreboard count =
  let open Scoreboard in
  match Red.once (DB.scan "score" count) with
  | Ok players -> bye (to_string players)
  | Error err -> die (fail err)

let highscoreboard count =
  let open Scoreboard in
  match Red.once (DB.scan "highscore" count) with
  | Ok players -> bye (to_string players)
  | Error err -> die (fail err)

let player id =
  let open Player in
  match Red.once (DB.scan id) with
  | Ok player -> bye (to_string player)
  | Error err -> die (fail err)

let user id =
  let open User in
  let token = Env.require_exn "SLACK_BOT_TOKEN" in
  match Red.once (DB.touch id ~token) with
  | Ok (Some user) -> bye (to_string user)
  | Ok None -> bye "null"
  | Error err -> die (fail err)

let search_player q =
  let open Player in
  match Red.once (DB.search q ~count:10) with
  | Ok players -> bye (Players.to_string players)
  | Error err -> die (fail err)

let int = int_of_string

let () =
  match Sys.argv with
  | [| _; "msg" |] -> msg ()
  | [| _; "feed"; count |] -> feed (int count)
  | [| _; "feed:about"; player; count |] -> feed_about player (int count)
  | [| _; "scoreboard"; count |] -> scoreboard (int count)
  | [| _; "highscoreboard"; count |] -> highscoreboard (int count)
  | [| _; "player"; id |] -> player id
  | [| _; "user"; id |] -> user id
  | [| _; "player:search"; q |] -> search_player q
  | _ -> die "invalid args"
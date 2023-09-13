open Tokenbot
open Fun.Infix_syntax
open System

(**)
module Red = Redis_sync.Client

let () =
  try
    match
      read_line ()
      |> Base64.decode
      |! "failed to decode base64 input"
      |> Slack.AppMention.parse_json
      |! "failed to decode slack message"
      |> fun msg ->
      let db =
        let host = Env.get "REDIS_HOST" |? "localhost"
        and port = Env.get_int "REDIS_PORT" |? 6379 in
        try Red.connect { host; port } with
        | _ -> die "failed to connect to redis"
      in
      let task =
        let dice = Dice.dice_random () in
        let rules = Rules.Collection.init ~dice
        and exchange = Rules.Exchange.exchange in
        let token =
          Env.require "SLACK_BOT_TOKEN"
          |! "missing required env param SLACK_BOT_TOKEN"
        in
        Engine.run msg ~token ~db ~rules ~exchange
      in
      let thanks = Lwt_main.run task in
      let _ = Red.disconnect db in
      thanks
    with
    | Error err -> die (fail err)
    | Ok thx -> bye (Thanks.show thx)
  with
  | exn -> die (fail exn)
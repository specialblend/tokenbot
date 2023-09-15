open Tokenbot
open Fun.Infix_syntax
open System

(**)
module Red = Redis_sync.Client

let dice = Dice.dice_random ()
let rules = Rules.Collection.init ~dice
let exchange = Rules.Exchange.exchange

let token =
  Env.require "SLACK_BOT_TOKEN" |! "missing required env param SLACK_BOT_TOKEN"

let db =
  let host = Env.get "REDIS_HOST" |? "localhost"
  and port = Env.get_int "REDIS_PORT" |? 6379 in
  try Red.connect { host; port } with
  | _ -> die "failed to connect to redis"

let () =
  try
    match
      read_line ()
      |> Base64.decode
      |! "failed to decode base64 input"
      |> Slack.AppMention.parse_json
      |! "failed to decode slack message"
      |> Engine.run ~token ~db ~rules ~exchange
      |> Lwt_main.run
      |> fun thanks ->
      Red.disconnect db;
      thanks
    with
    | Error err -> die (fail err)
    | Ok thx -> bye (Thanks.show thx)
  with
  | exn -> die (fail exn)

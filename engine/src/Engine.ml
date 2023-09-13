open Fun
open Fun.Let_syntax

(**)
module Deposit = Thanks.Deposit
module Cooldown = Item.Cooldown

type rule = Thanks.t -> Deposit.t list -> Deposit.t list

module Cashier = struct
  let collect_deposits thanks ~(rules : rule list) =
    rules |> List.fold_left (fun deposits rule -> rule thanks deposits) []

  let stack_items deposits items =
    deposits
    |> List.map Deposit.item
    |> List.fold_left Item.stack items
    |> List.map (Item.map_qty (max 0))

  let stack_cooldowns deposits cooldowns =
    deposits
    |> List.filter_map Deposit.token_cooldown
    |> List.fold_left Item.stack cooldowns
    |> List.map (Item.map_qty (max 0))

  let distribute deposits player =
    let deposits = deposits |> List.filter (Deposit.belongs_to player) in
    player |> Player.with_items (stack_items deposits) |> Player.recalculate

  let execute thx ~rules ~exchange =
    let sender, recipients = Thanks.parts thx in
    let everyone = sender :: recipients in

    let collected = collect_deposits thx ~rules in
    let players_tmp = everyone |> List.map (distribute collected) in
    let exchanged = exchange players_tmp in

    let deposits = exchanged @ collected in

    let sender =
      sender
      |> Player.with_cooldowns (stack_cooldowns deposits)
      |> distribute deposits
    in
    let recipients = recipients |> List.map (distribute deposits) in

    { thx with sender; recipients; deposits }
end

module Receptionist = struct
  let split_words = Str.split (Str.regexp " ")

  let parse_mention =
    function%pcre
    | {|(<@(?<user_id>\w+)>)|} -> Some user_id
    | _ -> None

  let parse_emoji =
    function%pcre
    | {|((?<shortcode>:\w+:))|} -> Token.from_shortcode shortcode
    | _ -> None

  let parse_mentions text =
    text
    |> split_words
    |> List.filter_map (fun word -> parse_mention word)
    |> Str.dedupe

  let parse_emojis text =
    text
    |> split_words
    |> List.filter_map (fun word -> parse_emoji word)
    |> Str.dedupe

  let mention player = fmt "<@%s>" (Player.id player)

  let fmt_qty = function
    | qty when qty >= 0 -> fmt "%i" qty
    | qty -> fmt "(%i)" qty

  let fmt_deposit Deposit.{ item = token, qty; about; cooldown } =
    let q = fmt_qty qty in
    match cooldown with
    | None -> fmt "%s `x%s %s`" token q about
    | Some duration ->
        duration
        |> Cooldown.format
        |> fmt "%s `x%s %s (cooldown: %s)`" token q about

  let fmt_group (player, deposits) =
    deposits
    |> List.map fmt_deposit
    |> List.cons (mention player)
    |> List.cons ""

  let fmt_thanks thanks =
    thanks
    |> Thanks.deposits
    |> Lst.group_by Deposit.player
    |> List.concat_map fmt_group
    |> String.concat "\n"

  let notify thx ~token =
    let open Slack in
    let emoji = "white_check_mark" in
    let msg = Thanks.msg thx
    and txt = fmt_thanks thx in
    let@! () = msg |> PostMessage.(reply txt >> post ~token)
    and@! () = msg |> AddReaction.(react emoji >> post ~token) in
    ()
end

module Engine = struct
  module Msg = Slack.AppMention
  module R = Receptionist

  let construct msg ~token ~db =
    let Msg.{ client_msg_id = id; text; user } = msg in

    let lookup = DB.lookup_player ~token ~db
    and filter_map = Lwt_list.filter_map_p in

    let tokens = R.parse_emojis text
    and mentions = R.parse_mentions text in

    let@ user = lookup user
    and@ mentions = filter_map lookup mentions in

    let*? sender = user in
    let recipients =
      mentions
      |> Lst.reject Player.is_bot
      |> Lst.sort_uniq Player.compare
      |> Lst.take 10
    in
    Thanks.make id ~msg ~tokens ~sender ~recipients

  let run msg ~token ~db ~rules ~exchange =
    let construct = construct ~token ~db
    and execute = Cashier.execute ~rules ~exchange
    and publish = DB.publish ~db
    and tap_notify thanks =
      let@! () = R.notify thanks ~token in
      thanks
    in
    msg
    |> construct
    |> Lwt.map (Opt.to_res (Failure "invalid message"))
    |> Lwt.map (Res.map execute)
    |> Lwt.map (Res.tap publish)
    |> Lwt_res.flat_map tap_notify
end

include Engine
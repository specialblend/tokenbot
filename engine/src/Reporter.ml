open Format
open Fun

let fmt_deposit Deposit.{ token; qty; about } =
  let q =
    match qty with
    | qty when qty >= 0 -> sprintf "%i" qty
    | qty -> sprintf "(%i)" qty
  in
  sprintf "%s `x%s %s`" token q about

let fmt_txn (target, deposits) =
  let target' = Mentions.fmt target in
  let lines = List.map fmt_deposit deposits in
  let lines' = String.concat "\n" lines in
  sprintf "%s\n%s" target' lines'

let fmt_thanks Thanks.{ txns } =
  let lines = List.map fmt_txn txns in
  String.concat "\n" lines

let react_to msg ~emoji ~token =
  let open Slack.AddReaction in
  let Msg.{ channel; ts } = msg in
  let payload = { channel; timestamp = ts; name = emoji } in
  Lwt_main.run (post payload ~token)

let reply_to msg ~text ~token =
  let open Slack.PostMessage in
  let Msg.{ ts; channel } = msg in
  let payload = { channel; text; thread_ts = Some ts } in
  Lwt_main.run (post payload ~token)

let print_exn e = print_endline (Printexc.to_string e)

let report thanks ~token =
  let Thanks.{ msg } = thanks
  and text = fmt_thanks thanks in
  match reply_to msg ~text ~token with
  | Error e -> (
      print_exn e;
      let emoji = "thumbsup" in
      match react_to msg ~emoji ~token with
      | Error e -> print_exn e
      | _ -> ())
  | _ -> ()
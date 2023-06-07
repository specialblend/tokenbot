open Deposit
open Fun
open Thanks

type io = {
  db: Red.connection;
  dice: int -> int;
}

let collect_tokens ?(dice = Dice.roll) thanks ~rules ~db =
  let io = { db; dice } in
  let into deposits rule = rule thanks deposits io in
  List.fold rules into []

let diff_scores (a, b) =
  if Player.(a.id = b.id) then
    Some (a.id, b.score - a.score)
  else
    None

let get_deferred_qty deposits player token ~db =
  let qty = Inventory.get_qty player token ~db in
  let into total deposit = total + deposit.qty in
  let deposits' = deposits ->. List.filter (Deposit.token_eq token) in
  List.fold deposits' into qty

let exchange (token, qty) ~use thx deposits io =
  let { db } = io
  and xchg_tokens player =
    let reset = give player ~qty:(-qty) token "exchange"
    and deposits = use player io in
    reset :: deposits
  in
  let get_qty' = get_deferred_qty deposits ~db in
  List.(
    thx
    ->. everyone
    ->. filter (fun player -> get_qty' player token >= qty)
    ->. concat_map xchg_tokens
    ->. append deposits)

let exchange_fixed item1 item2 =
  let fixed player _ =
    let token, qty = item2 in
    [ give player ~qty token "exchange" ]
  in
  exchange item1 ~use:fixed

let diff thanks players ~db =
  List.(
    thanks
    ->. everyone
    ->. map (Player.DB.scan_publish ~db)
    ->. combine players
    ->. filter_map diff_scores)

let exec thanks ~rules ~db ~token =
  let open Thanks in
  let deposits = collect_tokens thanks ~rules ~db in
  let players = thanks ->. everyone ->. List.map (Player.DB.scan ~db) in

  deposits ->. List.map_ignore (Inventory.exec ~db);
  deposits ->. List.map_ignore (thanks ->. sender ->. Cooldown.exec ~db);

  let diffs = diff thanks players ~db
  and txns = deposits ->. List.group_by Deposit.target in

  let thx = { thanks with txns; diffs } in

  Thanks.DB.publish thx ~db;
  Reporter.report thx ~token;

  Ok thx
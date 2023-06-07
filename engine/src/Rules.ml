open Fun
open Clock
open List
open Math
open Thanks
open Cashier
open Deposit

let bonus_tokens = [ "🌮"; "🍻"; "☕️"; "🌶️" ]
let pepper = Str.regexp {|.*:hot_pepper:.*|}
let fire = Str.regexp {|.*:fire:.*|}

let base thx deposits _ =
  let sender, recipients = Thanks.parts thx in
  let ticket =
    let qty = List.length recipients in
    give ~qty sender "🏷️" "receipt"
  in
  recipients
  ->. map (fun player -> give player "🌮" "thanks")
  ->. append (ticket :: deposits)

let super thx deposits { db } =
  let sender = thx ->. sender in
  if Msg.matches pepper thx.msg then
    if Cooldown.has "🌶️" sender ~db then
      let warning = Cooldown.warn sender "🌶️" in
      warning :: deposits
    else
      let cooldown = Duration.hours 8 in
      thx
      ->. recipients
      ->. map (fun player -> give ~cooldown player "🌶️" "super thanks")
      ->. append deposits
  else
    deposits

let hyper thx deposits { db } =
  let sender = thx ->. sender in
  if Msg.matches fire thx.msg then
    if Cooldown.has "🔥" sender ~db then
      let warning = Cooldown.warn sender "🔥" in
      warning :: deposits
    else
      let cooldown = Duration.hours 120 in
      thx
      ->. recipients
      ->. map (fun player -> give ~cooldown player "🔥" "hyper thanks")
      ->. append deposits
  else
    deposits

let happy_hour thx deposits { db } =
  let now = Player.time thx ~db in
  thx
  ->. everyone
  ->. filter (fun player -> hour (now player) ->. between (16, 18))
  ->. map (fun player -> give player "🍻" "happy hour")
  ->. append deposits

let monday thx deposits { db } =
  let now = Player.time thx ~db in
  thx
  ->. recipients
  ->. filter (fun player -> weekday (now player) == Mon)
  ->. map (fun player -> give player "☕️" "monday")
  ->. append deposits

let friday thx deposits { db } =
  let now = Player.time thx ~db in
  thx
  ->. everyone
  ->. filter (fun player -> weekday (now player) == Fri)
  ->. map (fun player -> give player "🍻" "TGIF")
  ->. append deposits

let st_paddy thx deposits { db } =
  let now = Player.time thx ~db in
  thx
  ->. everyone
  ->. filter (fun player -> Holiday.is_stpaddy (now player))
  ->. map (fun player -> give player ~qty:5 "🍻" "st. paddy")
  ->. append deposits

let halloween thx deposits { db } =
  let now = Player.time thx ~db in
  thx
  ->. recipients
  ->. filter (fun player -> Holiday.is_halloween (now player))
  ->. map (fun player -> give player "🎃" "trick or treat")
  ->. append deposits

let self_penalty thx deposits _ =
  let sender, recipients = parts thx in
  if recipients ->. includes sender then
    deposits
    ->. reject (fun deposit -> deposit.target = sender)
    ->. append [ give sender "💀" "self-mention penalty" ]
  else
    deposits

let luck_bonus thx deposits { db; dice } =
  let roll = dice 100 in
  let token = Tokens.(roll bonus_tokens ~dice) in
  thx
  ->. recipients
  ->. filter (fun player -> Stats.get_luck player ~db > roll)
  ->. map (fun player -> give player token "luck bonus")
  ->. append deposits

let exchange_tacos = Cashier.exchange_fixed ("🌮", 50) ("🔥", 1)
let exchange_peppers = Cashier.exchange_fixed ("🌶️", 10) ("🔥", 1)
let exchange_coffees = Cashier.exchange_fixed ("☕", 25) ("🔥", 1)
let exchange_beers = Cashier.exchange_fixed ("🍻", 25) ("🍀", 1)

let exchange_tickets =
  let roll_token player { dice } =
    let token = Tokens.roll bonus_tokens ~dice in
    [ give player token "exchange" ]
  in
  Cashier.exchange ("🏷️", 50) ~use:roll_token

let exchange_warnings = Cashier.exchange_fixed ("⚠️", 3) ("💀", 1)

let rules =
  [
    base;
    super;
    hyper;
    happy_hour;
    monday;
    friday;
    st_paddy;
    halloween;
    luck_bonus;
    exchange_tacos;
    exchange_peppers;
    exchange_coffees;
    exchange_beers;
    exchange_tickets;
    exchange_warnings;
    self_penalty;
  ]
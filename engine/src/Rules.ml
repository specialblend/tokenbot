open Fun
open Fun.Infix_syntax
open System

(**)
module Deposit = Thanks.Deposit

module Collection = struct
  let base thx deposits =
    let sender, recipients = Thanks.parts thx in
    let givable_tokens =
      thx
      |> Thanks.tokens
      |> List.filter Token.givable
      |> List.sort_uniq String.compare
      |> List.touch [ Token.fallback "🌮" ]
    in
    let give players token =
      let cooldown = Token.cooldown token in
      List.map (fun player -> Deposit.give player token ?cooldown) players
    in
    let check token =
      match Player.cooldown token sender with
      | None -> give recipients token
      | Some cooldown ->
          let warning =
            let about = Item.Cooldown.describe (token, cooldown) in
            Deposit.give sender "⚠️" ~about
          in
          warning :: give recipients (Token.fallback token)
    in
    let receipt =
      let qty = List.length recipients in
      Deposit.give sender "🏷️" ~qty
    in
    givable_tokens
    |> List.concat_map check
    |> List.cons receipt
    |> List.append deposits

  let monday thx deposits =
    let is_monday player =
      let now = Thanks.local_time thx player in
      Clock.weekday now = Clock.Mon
    in
    thx
    |> Thanks.recipients
    |> List.filter (fun player -> is_monday player)
    |> List.map (fun player -> Deposit.give player "☕️" ~about:"monday")
    |> List.append deposits

  let friday thx deposits =
    let is_friday player =
      let now = Thanks.local_time thx player in
      Clock.weekday now = Clock.Fri
    in
    thx
    |> Thanks.recipients
    |> List.filter (fun player -> is_friday player)
    |> List.map (fun player -> Deposit.give player "🍻" ~about:"TGIF")
    |> List.append deposits

  let happy_hour thx deposits =
    let is_happy_hour player =
      let now = Thanks.local_time thx player in
      Clock.hour now |> between (16, 18)
    in
    thx
    |> Thanks.everyone
    |> List.filter (fun player -> is_happy_hour player)
    |> List.map (fun player -> Deposit.give player "🍻" ~about:"happy hour")
    |> List.append deposits

  let st_paddy thx deposits =
    let is_st_paddy player =
      let now = Thanks.local_time thx player in
      Clock.month now = 3 && Clock.mday now |> between (17, 18)
    in
    thx
    |> Thanks.everyone
    |> List.filter (fun player -> is_st_paddy player)
    |> List.map (fun player -> Deposit.give player "🍀" ~about:"st paddy")
    |> List.append deposits

  let halloween thx deposits =
    let is_halloween player =
      let now = Thanks.local_time thx player in
      Clock.month now = 10 && Clock.mday now >= 21
    in
    thx
    |> Thanks.everyone
    |> List.filter (fun player -> is_halloween player)
    |> List.map (fun player -> Deposit.give player "🎃" ~about:"trick or treat")
    |> List.append deposits

  let holiday_season thx deposits =
    let is_holiday_season player =
      let now = Thanks.local_time thx player in
      Clock.month now = 12 && Clock.mday now >= 21
    in
    thx
    |> Thanks.everyone
    |> List.filter (fun player -> is_holiday_season player)
    |> List.map (fun player -> Deposit.give player "🎁" ~about:"happy holidays")
    |> List.append deposits

  let navruz thx deposits =
    let is_navruz player =
      let now = Thanks.local_time thx player in
      Clock.month now = 3 && Clock.mday now >= 21
    in
    thx
    |> Thanks.everyone
    |> List.filter (fun player -> is_navruz player)
    |> List.map (fun player -> Deposit.give player "🔥" ~about:"happy navruz")
    |> List.append deposits

  let lucky thx deposits ~dice =
    let r = dice 100 in
    thx
    |> Thanks.recipients
    |> List.filter (fun player -> Player.luck player > r)
    |> List.map (fun player -> Deposit.give player "🎁" ~about:"luck bonus")
    |> List.append deposits

  let gift_box thx deposits ~dice =
    let is_gift_box = function
      | "🎁", qty when qty >= 1 -> true
      | _ -> false
    in
    let sender = Thanks.sender thx in
    let open_box _item =
      let qty = 5 in
      let tokens = Token.roll_many Token.luck_bonus ~dice ~qty in
      let items =
        tokens |> List.map Item.make |> List.fold_left Item.stack []
      in
      let got =
        List.map
          (fun (token, qty) -> Deposit.give sender token ~qty ~about:"bonus")
          items
      in
      let opened = Deposit.give sender "🎁" ~qty:(-1) ~about:"opened" in
      opened :: got
    in
    sender
    |> Player.items
    |> List.filter (fun item -> is_gift_box item)
    |> List.concat_map (fun item -> open_box item)
    |> List.append deposits

  let self_penalty thx deposits =
    let sender, recipients = Thanks.parts thx in
    if List.mem sender recipients then
      let penalize player =
        Deposit.give player "💀" ~about:"self-mention penalty"
      in
      let forfeit player = List.reject (Deposit.belongs_to player) in
      penalize sender :: forfeit sender deposits
    else
      deposits

  let init ~dice =
    [
      base;
      monday;
      friday;
      happy_hour;
      st_paddy;
      halloween;
      lucky ~dice;
      gift_box ~dice;
      self_penalty;
    ]
end

module Exchange = struct
  let do_exchange ?about player ~take:(token1, qty1) ~give:(token2, qty2) =
    let about = about |? "exchange" in
    [
      Deposit.give player token1 ~qty:(-qty1) ~about;
      Deposit.give player token2 ~qty:qty2 ~about;
    ]

  let exchange_item player =
    let xchg = do_exchange player in
    function
    | "🌮", qty when qty >= 50 -> xchg ~take:("🌮", 50) ~give:("🔥", 1)
    | "☕️", qty when qty >= 25 -> xchg ~take:("☕", 25) ~give:("🔥", 1)
    | "🌶️", qty when qty >= 10 -> xchg ~take:("🌶️", 10) ~give:("🔥", 1)
    | "🍻", qty when qty >= 25 -> xchg ~take:("🍻", 25) ~give:("🍀", 1)
    | "🏷️", qty when qty >= 100 -> xchg ~take:("🏷️", 100) ~give:("🎁", 1)
    | "⚠️", qty when qty >= 3 -> xchg ~take:("⚠️", 3) ~give:("💀", 1)
    | _ -> []

  let exchange =
    List.concat_map (fun player ->
        player
        |> Player.items
        |> List.concat_map (fun item -> exchange_item player item))
end

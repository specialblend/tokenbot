open Fun

let scope token player =
  let key = Red.prefix player token in
  Red.prefix "cooldown" key

let has token player ~db =
  let key = scope token player in
  Red.exists db key

let put token player ttl ~db =
  let key = scope token player in
  void (Red.setex db key ttl ".")

let exec player deposit ~db =
  let Deposit.{ token; cooldown } = deposit in
  match cooldown with
  | Some cooldown -> void (put token player cooldown ~db)
  | None -> ()

let warn player token = Deposit.give player "⚠️" ("cooldown warning: " ++ token)
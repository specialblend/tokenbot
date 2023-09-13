open System

(**)
module Duration = Clock.Duration

let points = function
  | "🌮" -> 1
  | "🍻" -> 1
  | "☕️" -> 1
  | "🍀" -> 1
  | "🎃" -> 1
  | "🌶️" -> 3
  | "🔥" -> 7
  | "🍉" -> 13
  | "🏷️" -> 0
  | "🎁" -> 0
  | "💀" -> -5
  | _ -> 0

let bonus = function
  | "🌶️" -> 1
  | "🔥" -> 20
  | "💀" -> -10
  | _ -> 0

let luck = function
  | "🍀" -> 20
  | "💀" -> -10
  | _ -> 0

let cooldown = function
  | "🌶️" -> Some (Duration.hours 8)
  | "🔥" -> Some (Duration.hours 120)
  | _ -> None

let about = function
  | "🌮" -> "thanks"
  | "🏷️" -> "receipt"
  | "🌶️" -> "super thanks"
  | "🔥" -> "hyper thanks"
  | "🍀" -> "st paddy"
  | "🎃" -> "trick or treat"
  | "💀" -> "penalty"
  | _ -> "thanks"

let from_shortcode = function
  | ":beers:" -> Some "🍻"
  | ":coffee:" -> Some "☕️"
  | ":fire:" -> Some "🔥"
  | ":four_leaf_clover:" -> Some "🍀"
  | ":heart:" -> Some "❤️"
  | ":hot_pepper:" -> Some "🌶️"
  | ":label:" -> Some "🏷️"
  | ":skull:" -> Some "💀"
  | ":taco:" -> Some "🌮"
  | _ -> None

let fallback = function
  | _ -> "🌮"

let givable = function
  | "🌮" -> true
  | "🌶️" -> true
  | "🔥" -> true
  | _ -> false

let luck_bonus = [ "🌮"; "🍻"; "☕️"; "🎃"; "🌶️"; "🔥"; "🍀"; "🍉" ]

let roll_one tokens ~dice =
  let tokens = Array.of_list tokens in
  let n = Array.length tokens in
  let i = dice n - 1 in
  try Array.get tokens i with
  | _ -> "🌮"

let roll_many tokens ~qty ~dice =
  let rec loop acc = function
    | 0 -> acc
    | qty ->
        let token = roll_one tokens ~dice in
        loop (token :: acc) (qty - 1)
  in
  loop [] qty
open Fun

let points = function
  | "🌮" -> 1
  | "🍻" -> 1
  | "☕️" -> 1
  | "🍀" -> 1
  | "🎃" -> 1
  | "🌶️" -> 3
  | "🔥" -> 7
  | "🏷️" -> 0
  | "💀" -> -1
  | _ -> 0

type fx =
  | Greed of int
  | Luck of int
  | Bonus of int

let fx = function
  | "🌶️" -> [ Bonus 1 ]
  | "🔥" -> [ Bonus 20 ]
  | "🍀" -> [ Luck 20 ]
  | "🎃" -> [ Greed 20 ]
  | "💀" -> [ Bonus (-20) ]
  | _ -> []

let shortcodes =
  [
    (":beers:", "🍻");
    (":coffee:", "☕️");
    (":fire:", "🔥");
    (":four_leaf_clover:", "🍀");
    (":heart:", "❤️");
    (":hot_pepper:", "🌶️");
    (":label:", "🏷️");
    (":skull:", "💀");
    (":taco:", "🌮");
  ]

let roll tokens ~dice =
  let len = List.length tokens in
  let index = dice len in
  let token = List.nth_opt tokens index ->. default "🌮" in
  token
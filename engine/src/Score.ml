open Tokens
open Fun

let calc_base items =
  let score = 0 in
  let value_of (token, qty) = points token * qty in
  let into total item = total + value_of item in
  List.fold items into score

let calc_bonus stats base =
  let Stats.{ bonus } = stats in
  let diff = bonus * base in
  let score = float_of_int diff /. 100. in
  int_of_float score

let calc stats items =
  let base = calc_base items in
  let score = base + calc_bonus stats base in
  max 0 score

let float = float_of_int

let get_highscore player score ~db =
  match Red.zscore db "highscore" player with
  | Some highscore -> max score (int_of_float highscore)
  | None -> score

let publish player score highscore ~db =
  void
    [
      Red.zadd db "score" [ (float score, player) ];
      Red.zadd db "highscore" [ (float highscore, player) ];
    ]
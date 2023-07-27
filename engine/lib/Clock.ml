open Unix
open Format
open Fun

type weekday =
  | Mon
  | Tue
  | Wed
  | Thu
  | Fri
  | Sat
  | Sun

let weekday tm =
  match tm.tm_wday with
  | 0 -> Sun
  | 1 -> Mon
  | 2 -> Tue
  | 3 -> Wed
  | 4 -> Thu
  | 5 -> Fri
  | 6 -> Sat
  | _ -> Mon

let month now = now.tm_mon + 1
let mday now = now.tm_mday
let hour now = now.tm_hour
let minute now = now.tm_min
let seconds now = now.tm_sec

module Duration = struct
  let hours x = x * 60 * 60
end
open Fun
module R = Redis_sync.Client

let get = trap2 R.get
let lpush = trap3 R.lpush
let ltrim db = trap3 (R.ltrim db)
let mget = trap2 R.mget
let setex db = trap3 (R.setex db)
let set db = trap2 (R.set db)
let zadd db = trap2 (R.zadd db)

let mget_safe db = function
  | [] -> Ok []
  | keys -> mget db keys

let scan_pattern db ~count =
  trap (fun pattern ->
      let rec scan' acc ~cursor =
        match R.scan db cursor ~pattern ~count with
        | 0, [] -> acc
        | 0, keys -> acc @ keys
        | cursor, keys -> scan' (acc @ keys) ~cursor
      in
      scan' [] ~cursor:0)

let lpush_rotate key ~id ~db ~limit =
  let trim = function
    | len when len >= limit -> ltrim db key 0 len
    | _ -> Ok ()
  in
  lpush db key [ id ] |> Result.flat_map trim
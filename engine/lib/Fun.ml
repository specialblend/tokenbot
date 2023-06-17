(* TODO move into own library package *)

let ( ++ ) = ( ^ )
let ( ->. ) = ( |> )
let ( ->: ) f g x = g (f x)
let apply x fn = fn x

let default x t =
  match t with
  | Some x -> x
  | None -> x

let try_wrap task =
  try Ok (task ()) with
  | e -> Error e

let try_catch fn task =
  try Ok (task ()) with
  | e -> Error (fn e)

let fail = Printexc.to_string

let bye msg =
  print_endline msg;
  exit 0

let die msg =
  output_string stderr msg;
  flush stderr;
  exit 1

let void = ignore

module Env = struct
  exception MissingEnv of string

  let get param =
    try Some (Sys.getenv param) with
    | _ -> None

  let require param =
    match get param with
    | Some x -> Ok x
    | None -> Error (MissingEnv param)

  let require_exn param =
    match get param with
    | Some x -> x
    | None -> raise (MissingEnv param)

  let get_int param =
    match get param with
    | Some x -> int_of_string_opt x
    | None -> None

  let get_float param =
    match get param with
    | Some x -> float_of_string_opt x
    | None -> None

  let get_bool param =
    match get param with
    | Some x -> x = "true"
    | None -> false
end

module Json = struct
  include Yojson.Safe

  let parse ~t_of_yojson str = t_of_yojson (from_string str)
  let stringify ~yojson_of_t t = to_string (yojson_of_t t)
end

module List = struct
  include List

  let dedupe_str t = sort_uniq String.compare t
  let fold l fn i = fold_left fn i l

  let head = function
    | h :: _ -> Some h
    | _ -> None

  let includes = mem
  let map_ignore fn = iter (fn ->: void)
  let reject fn l = filter (fun x -> not (fn x)) l

  let take n l =
    let _, res =
      List.fold_right
        (fun x (count, acc) ->
          if count < n then
            (count + 1, x :: acc)
          else
            (count, acc))
        l (0, [])
    in
    res

  let group_by lens items =
    let group key item = function
      | k, items when k = key -> (k, item :: items)
      | k, v -> (k, v)
    in
    let into pairs item =
      let key = lens item in
      if mem_assoc key pairs then
        map (group key item) pairs
      else
        (key, [ item ]) :: pairs
    in
    fold items into []
end

module Math = struct
  let between (a, b) x = x >= a && x < b
  let clamp (_min, _max) n = max _min (min _max n)
end

module Lwt = struct
  include Lwt

  let flat_map fn t = bind t fn
  let ( let* ) = bind
end

module Option = struct
  include Option

  let flat_map f t = bind t f
end

module Result = struct
  include Result

  let flat_map f t = bind t f
end

module String = struct
  include String

  let trim_empty = function
    | "" -> None
    | s -> Some s
end
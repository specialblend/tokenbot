(**)
include Ppx_yojson_conv_lib.Yojson_conv.Primitives
include Sexplib.Std

(**)
open System

(**)
let ( >> ) f g x = g (f x)

(**)
let always x _ = x
let between (a, b) x = x >= a && x < b
let clamp (lower, upper) n = max lower (min upper n)
let fmt = Format.sprintf

(* trap: try, catch, wrap *)
let trap f x =
  try Ok (f x) with
  | e -> Error e

let trap2 f x y =
  try Ok (f x y) with
  | e -> Error e

let trap3 f x y z =
  try Ok (f x y z) with
  | e -> Error e

let trap_opt f x =
  try Some (f x) with
  | _ -> None

(**)
module Str = struct
  include Str

  let dedupe l = List.sort_uniq String.compare l
end

module Lst = struct
  include List

  let head = function
    | [] -> None
    | h :: _ -> Some h

  let group_by lens items =
    let stack pairs item =
      let key = lens item in
      let items' =
        match assoc_opt key pairs with
        | Some items -> item :: items
        | None -> item :: []
      in
      (key, items') :: remove_assoc key pairs
    in
    fold_left stack [] items

  let map_ignore fn = map (fun x -> fn x |> ignore)
  let reject fn l = filter (fun x -> fn x |> not) l

  let take n l =
    let rec take acc n = function
      | [] -> rev acc
      | h :: t when n > 0 -> take (h :: acc) (n - 1) t
      | _ -> rev acc
    in
    take [] n l

  let touch default = function
    | [] -> default
    | l -> l
end

module Opt = struct
  include Option

  let both x y =
    match (x, y) with
    | Some a, Some b -> Some (a, b)
    | _ -> None

  let flat_map f t = bind t f
  let tap fn = map (fun x -> fn x |> always x)

  let to_res e = function
    | Some x -> Ok x
    | None -> Error e
end

module Res = struct
  include Result

  let both x y =
    match (x, y) with
    | Ok a, Ok b -> Ok (a, b)
    | Error e, _ -> Error e
    | _, Error e -> Error e

  let all l = List.fold_left (fun acc x -> bind acc (fun _ -> x)) (Ok ()) l
  let flat_map f t = bind t f
  let tap fn = map (fun x -> fn x |> always x)
  let from_opt = Opt.to_res
end

module Lwt_res = struct
  include Lwt_result

  let flat_map f t = bind t f
end

(**)
module Jsn = struct
  module J = Yojson.Safe

  let from_str = trap J.from_string
  let from_str_opt = trap_opt J.from_string
  let to_str = trap J.to_string
  let to_str_opt = trap_opt J.to_string
  let parse decoder = from_str >> Res.flat_map (trap decoder)
  let parse_opt decoder = from_str_opt >> Opt.flat_map (trap_opt decoder)
  let stringify encoder = trap encoder >> Res.flat_map to_str
  let stringify_opt encoder = trap_opt encoder >> Opt.flat_map to_str_opt
end

module Infix_syntax = struct
  let ( |? ) opt default =
    match opt with
    | Some x -> x
    | None -> default

  let ( |! ) res msg =
    match res with
    | Ok x -> x
    | Error _ -> die msg
end

module Let_syntax = struct
  (**)
  let ( let@ ) = Lwt.Syntax.( let+ )
  let ( and@ ) = Lwt.Syntax.( and+ )
  let ( let* ) = Lwt.Syntax.( let* )
  let ( and* ) = Lwt.Syntax.( and* )

  (**)
  let ( let*! ) x f = Res.map f x
  let ( and*! ) = Res.both
  let ( let*!! ) = Res.bind

  (**)
  let ( let*? ) x f = Opt.map f x
  let ( and*? ) = Opt.both
  let ( let*?? ) = Opt.bind

  (**)
  let ( let@! ) x f = Lwt.map (Res.map f) x
  let ( and@! ) x y = Lwt.bind x (fun a -> Lwt.map (fun b -> Res.both a b) y)
  let ( let@!* ) x f = Lwt.map (Res.flat_map f) x
  let ( and@!* ) = ( and@! )

  (**)
  let ( let@? ) x f = Lwt.map (Opt.map f) x
  let ( and@? ) x y = Lwt.bind x (fun a -> Lwt.map (fun b -> Opt.both a b) y)
  let ( let@?* ) x f = Lwt.map (Opt.flat_map f) x
  let ( and@?* ) = ( and@? )
end
open Contract

module Nat : NATURAL = struct
  type t = Nat of int

  let ( -! ) (Nat x) (Nat y) = Nat (max 0 (x - y))

  let ( - ) (Nat x) (Nat y) =
    match x - y with
    | z when z >= 0 -> Some (Nat z)
    | _ -> None

  let ( + ) (Nat x) (Nat y) = Nat (x + y)

  let make = function
    | x when x >= 0 -> Some (Nat x)
    | _ -> None
end

module Percentage : PERCENTAGE = struct
  include Nat
end

module Duration : DURATION = struct
  module Nat = Nat
  include Nat

  type t =
    | Seconds of Nat.t
    | Minutes of Nat.t
    | Hours of Nat.t
end

module Clock = struct
  open Unix

  type weekday =
    | Mon
    | Tue
    | Wed
    | Thu
    | Fri
    | Sat
    | Sun
  [@@deriving show]

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
    let seconds n = n
    let minutes n = n * 60
    let hours n = n * 3600
  end
end

module Dice = struct
  let dice_static n _sides = n

  let dice_sequential () =
    let i = ref 1 in
    fun sides ->
      i := !i + 1;
      !i mod sides

  let dice_random () =
    Random.self_init ();
    fun sides -> Random.int sides
end

module Env = struct
  exception Missing of string

  let get param =
    try Some (Sys.getenv param) with
    | _ -> None

  let require param =
    try Ok (Sys.getenv param) with
    | _ -> Error (Missing param)

  let get_int param =
    match get param with
    | Some x -> int_of_string_opt x
    | None -> None
end

module Y = Ppx_yojson_conv_lib__Yojson_conv

let rec fail = function
  | Y.Of_yojson_error (exn, _json) -> fail exn
  | exn -> failwith (Printexc.to_string exn)

let bye msg =
  output_string stdout msg;
  output_string stdout "\n";
  flush stdout;
  exit 0

let die msg =
  output_string stderr msg;
  output_string stderr "\n";
  flush stderr;
  exit 1

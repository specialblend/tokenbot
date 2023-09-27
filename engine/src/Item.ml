open Fun

module Cooldown = struct
  type t = string * int [@@deriving ord, show { with_path = false }, yojson]

  let normalize = function
    | n when n < 60 -> (n, `Seconds)
    | n when n < 3600 -> (n / 60, `Minutes)
    | n -> (n / 3600, `Hours)

  let fmt = function
    | 1, `Seconds -> Fmt.sprintf "%d+ second" 1
    | n, `Seconds -> Fmt.sprintf "~%d seconds" n
    | 1, `Minutes -> Fmt.sprintf "%d+ minute" 1
    | n, `Minutes -> Fmt.sprintf "~%d minutes" n
    | 1, `Hours -> Fmt.sprintf "%d+ hour" 1
    | n, `Hours -> Fmt.sprintf "~%d hours" n

  let format = normalize >> fmt

  let describe (token, cooldown) =
    Fmt.sprintf "cooldown warning for %s (%s)" token (format cooldown)

  let pp fmt (token, duration) = Fmt.fprintf fmt "(\"%s\", %d)" token duration
end

module Item = struct
  type t = string * int [@@deriving ord, yojson]

  let pp fmt (token, qty) = Fmt.fprintf fmt "(\"%s\", %d)" token qty
  let show (token, qty) = Fmt.sprintf "(\"%s\", %d)" token qty
  let make ?(qty = 1) token = (token, qty)
  let map_qty fn (token, qty) = (token, fn qty)

  let stack items (token, qty) =
    let qty' =
      match List.assoc_opt token items with
      | Some q -> qty + q
      | None -> qty
    in
    (token, qty') :: List.remove_assoc token items
end

include Item

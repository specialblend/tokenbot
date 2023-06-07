include Slack.AppMention

let matches regex t = Str.(string_match regex t.text 0)

let tm ?offset t =
  let ts = float_of_string t.ts in
  match offset with
  | Some offset -> Unix.gmtime (ts +. float_of_int offset)
  | None -> Unix.localtime ts

let is_edited = function
  | { edited = Some _ } -> true
  | _ -> false

let from_json str =
  let module J = Yojson.Safe in
  try Some (t_of_yojson (J.from_string str)) with
  | _ -> None

let from_base64 str =
  match Base64.decode str with
  | Ok str -> Some str
  | _ -> None

let parse str =
  match from_base64 str with
  | Some str -> from_json str
  | _ -> None
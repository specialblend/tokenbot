open Fun

let words = Str.(split (regexp " "))

let parse =
  function%pcre
  | {|(<@(?<user_id>\w+)>)|} -> Some user_id
  | _ -> None

let parse_all text = List.filter_map parse (words text)
let fmt user_id = Format.sprintf "<@%s>" user_id

let scan msg ~token ~db =
  let touch = User.DB.touch ~token ~db in
  match User.DB.me ~token ~db with
  | None -> None
  | Some me -> (
      let Msg.{ text; user } = msg in
      let mentions =
        parse_all text
        ->. List.dedupe_str
        ->. List.reject (( = ) me)
        ->. List.take 10
      in
      let everyone = me :: user :: mentions in
      List.map_ignore touch everyone;
      match mentions with
      | [] -> None
      | recipients -> Some (me, user, recipients))
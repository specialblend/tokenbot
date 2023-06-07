open Fun
open Slack
open Slack.User

let to_string = User.to_string
let display_name = User.profile ->: Profile.display_name ->: String.trim_empty

let normalize =
  String.lowercase_ascii ->: Str.global_replace (Str.regexp "[^A-Za-z]") ""

module DB = struct
  let scope = Red.prefix "user"

  let index_name user ~db =
    let { id; name; real_name; profile } = user in
    let Profile.{ display_name } = profile in
    [ name; real_name; display_name ]
    ->. List.map normalize
    ->. List.map_ignore (fun name -> Red.hset db "names" name id)

  let put user ~db =
    let key = scope (id user)
    and value = to_string user in
    void (Red.set db key value);
    void (index_name user ~db);
    user

  let fetch_insert id ~token ~db =
    Slack.UserInfo.get id ~token
    ->. Lwt.map (Option.map (put ~db))
    ->. Lwt_main.run

  let get id ~db =
    let key = scope id in
    Red.get db key ->. Option.map from_string

  let get_name ~db =
    get ~db
    ->: Option.map
          (Option.map_either display_name
             (Option.map_either (real_name ->: String.trim_empty) name))

  let get_is_bot ~db = get ~db ->: Option.map is_bot ->: default false
  let get_tz_offset ~db = get ~db ->: Option.map tz_offset

  let me ~token ~db =
    match Red.get db "me" with
    | Some me -> Some me
    | None ->
        Lwt_main.run
          (match%lwt Slack.me ~token with
          | Ok me ->
              let _ = Red.set db "me" me in
              Lwt.return (Some me)
          | Error _ -> Lwt.return None)

  let search q ~count ~db =
    let open Format in
    let pattern = sprintf "%s*" q in
    let _, results = Red.hscan db "names" 0 ~pattern ~count in
    results ->. List.map (fun (_, id) -> id) ->. List.dedupe_str

  let touch id ~token ~db =
    match get id ~db with
    | Some user when User.id user = id -> Some user
    | _ -> fetch_insert id ~token ~db
end
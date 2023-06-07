open Fun

exception Failed of string option

let fmt_headers token =
  [
    ("Accept", "application/json");
    ("Authorization", "Bearer " ++ token);
    ("Content-Type", "application/json");
  ]

module Response = struct
  type t = {
    ok: bool;
    error: string option; [@yojson.default None]
  }
  [@@deriving fields, show, yojson] [@@yojson.allow_extra_fields]

  let expect_ok json =
    match t_of_yojson json with
    | { ok = true } -> Ok json
    | { error } -> Error (Failed error)
end

let expect_ok = Result.flat_map Response.expect_ok

module Profile = struct
  type t = {
    title: string;
    phone: string;
    skype: string;
    real_name: string;
    real_name_normalized: string;
    display_name: string;
    display_name_normalized: string;
    fields: string option;
    status_text: string;
    status_emoji: string;
    status_emoji_display_info: string list;
    status_expiration: int;
    avatar_hash: string;
    first_name: string;
    last_name: string;
    image_24: string;
    image_32: string;
    image_48: string;
    image_72: string;
    image_192: string;
    image_512: string;
    status_text_canonical: string;
    team: string;
  }
  [@@deriving fields, show, yojson] [@@yojson.allow_extra_fields]

  let to_string = Json.stringify ~yojson_of_t
end

module User = struct
  type t = {
    id: string;
    team_id: string;
    name: string;
    deleted: bool;
    color: string;
    real_name: string;
    tz: string;
    tz_label: string;
    tz_offset: int;
    is_admin: bool;
    is_owner: bool;
    is_primary_owner: bool;
    is_restricted: bool;
    is_ultra_restricted: bool;
    is_bot: bool;
    is_app_user: bool;
    updated: int;
    is_email_confirmed: bool;
    who_can_share_contact_card: string;
    profile: Profile.t;
  }
  [@@deriving fields, show, yojson] [@@yojson.allow_extra_fields]

  let from_string = Json.parse ~t_of_yojson
  let to_string = Json.stringify ~yojson_of_t
end

module AppMention = struct
  type edited = {
    user: string;
    ts: string;
  }
  [@@deriving show, yojson]

  type t = {
    client_msg_id: string;
    channel: string;
    edited: edited option; [@yojson.option]
    event_ts: string;
    team: string;
    text: string;
    thread_ts: string option; [@yojson.default None]
    ts: string;
    user: string;
  }
  [@@yojson.allow_extra_fields] [@@deriving show, yojson]
end

module AuthTest = struct
  type t = {
    url: string;
    team: string;
    user: string;
    team_id: string;
    user_id: string;
    bot_id: string option; [@yojson.optional]
  }
  [@@yojson.allow_extra_fields] [@@deriving fields, show, yojson]

  let parse = Result.map t_of_yojson

  let get ~token =
    let headers = fmt_headers token in
    Fetch.fetch_json "https://slack.com/api/auth.test" ~headers
    ->. Lwt.map (expect_ok ->: parse)
end

module AddReaction = struct
  type t = {
    channel: string;
    name: string;
    timestamp: string;
  }
  [@@deriving show, yojson]

  let post t ~token =
    let headers = fmt_headers token
    and json = yojson_of_t t in
    Fetch.post_json "https://slack.com/api/reactions.add" ~headers ~json
    ->. Lwt.map expect_ok
end

module PostMessage = struct
  type t = {
    channel: string;
    thread_ts: string option; [@yojson.optional]
    text: string;
  }
  [@@deriving show, yojson]

  let post t ~token =
    let headers = fmt_headers token
    and json = yojson_of_t t in
    Fetch.post_json "https://slack.com/api/chat.postMessage" ~headers ~json
    ->. Lwt.map expect_ok
end

module UserInfo = struct
  type t = { user: User.t }
  [@@deriving fields, show, yojson] [@@yojson.allow_extra_fields]

  let parse = Result.map (t_of_yojson ->: user)

  let get id ~token =
    Fetch.fetch_json "https://slack.com/api/users.info"
      ~headers:(fmt_headers token)
      ~params:[ ("user", [ id ]) ]
    ->. Lwt.map (expect_ok ->: parse ->: Result.to_option)
end

let me ~token = AuthTest.(get ~token ->. Lwt.map (Result.map user_id))
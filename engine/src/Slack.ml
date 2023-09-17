open Fun
open Fun.Let_syntax
(* open Contract *)

exception Failed of string

module Request = struct
  let headers token =
    Cohttp.Header.of_list
      [
        ("Accept", "application/json");
        ("Authorization", "Bearer " ^ token);
        ("Content-Type", "application/json");
      ]
end

module Response = struct
  type t = {
    ok: bool;
    error: string option; [@yojson.default None]
  }
  [@@deriving yojson] [@@yojson.allow_extra_fields]

  let parse = trap t_of_yojson

  let parse_ok =
    let expect_ok json =
      match parse json with
      | Error e -> Error e
      | Ok { ok = true } -> Ok json
      | Ok { error = Some err } -> Error (Failed err)
      | Ok { error = None } -> Error (Failed "unknown error")
    in
    Res.flat_map expect_ok
end

module User = struct
  type id = string [@@deriving yojson]

  type t = {
    id: id;
    name: string;
    tz_offset: int;
    is_bot: bool;
  }
  [@@deriving fields, yojson]
end

module R = Response

module AppMention = struct
  module Usr = User

  type edited = {
    user: string;
    ts: string;
  }
  [@@deriving ord, make, show { with_path = false }, yojson]

  type id = string [@@deriving yojson]
  type ts = string [@@deriving yojson]
  type text = string [@@deriving yojson]
  type channel = string [@@deriving yojson]
  type thread = string [@@deriving yojson]

  type t = {
    client_msg_id: string; [@default "example_app_mention_id"]
    channel: channel; [@default "EXAMPLE"]
    edited: edited option; [@default None]
    event_ts: string; [@default "0000000000.000000"]
    team: string; [@default "TDEADBEEF"]
    text: string; [@default "Hello world"]
    thread_ts: thread option; [@default None]
    ts: ts; [@default "0000000000.000000"]
    user: User.id;
  }
  [@@deriving fields, yojson]
  (* [@@deriving ord, fields, make, show { with_path = false }, yojson] *)
  [@@yojson.allow_extra_fields]

  let id = client_msg_id
  let user_id = user
  let thread = thread_ts
  (* let parse_json = Jsn.parse t_of_yojson *)
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
  [@@yojson.allow_extra_fields] [@@deriving yojson]

  let get ~token =
    let uri = Uri.of_string "https://slack.com/api/auth.test"
    and headers = Request.headers token in
    let@ data = Fetch.get_json ~uri ~headers in
    data |> R.parse_ok |> Res.flat_map (trap t_of_yojson)
end

module AddReaction = struct
  module Msg = AppMention

  type t = {
    channel: AppMention.channel;
    timestamp: AppMention.ts;
    name: string;
  }
  [@@deriving yojson]

  let react emoji parent =
    let channel = AppMention.channel parent
    and timestamp = AppMention.ts parent in
    { channel; timestamp; name = emoji }

  let post t ~token =
    let uri = Uri.of_string "https://slack.com/api/reactions.add"
    and headers = Request.headers token
    and json = yojson_of_t t in

    let@ data = Fetch.post_json ~uri ~headers ~json in
    data |> R.parse_ok |> Res.map ignore
end

module PostMessage = struct
  type t = {
    channel: string;
    thread_ts: string option; [@yojson.optional]
    text: string;
  }
  [@@deriving yojson]

  let post t ~token =
    let uri = Uri.of_string "https://slack.com/api/chat.postMessage"
    and headers = Request.headers token
    and json = yojson_of_t t in

    let@ data = Fetch.post_json ~uri ~headers ~json in
    data |> R.parse_ok |> Res.map ignore

  let reply text parent =
    let channel = AppMention.channel parent
    and thread_ts = Some (AppMention.ts parent) in
    { channel; thread_ts; text }
end

module UserInfo = struct
  type t = { user: User.t } [@@deriving yojson] [@@yojson.allow_extra_fields]

  let get id ~token =
    let base_uri = Uri.of_string "https://slack.com/api/users.info"
    and params = [ ("user", [ id ]) ] in

    let uri = Uri.add_query_params base_uri params
    and headers = Request.headers token in

    let@ data = Fetch.get_json ~uri ~headers in
    data
    |> R.parse_ok
    |> Res.flat_map (trap t_of_yojson)
    |> Res.map (fun { user } -> user)
end

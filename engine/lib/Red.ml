open Fun
include Redis_sync.Client

exception NoRedis of exn

let prefix p s = Format.sprintf "%s:%s" p s

let get_opts () =
  Option.(
    let host = Env.get "REDIS_HOST" ->. default "localhost"
    and port = Env.get_int "REDIS_PORT" ->. default 6379 in
    { host; port })

let once_bind ?(opts = get_opts ()) task =
  match try_wrap (fun () -> connect opts) with
  | Error e -> Error (NoRedis e)
  | Ok db ->
      let res = task ~db in
      let _ = quit db in
      res

let once ?(opts = get_opts ()) task =
  match try_wrap (fun () -> connect opts) with
  | Error e -> Error (NoRedis e)
  | Ok db ->
      let res = task ~db in
      let _ = quit db in
      Ok res
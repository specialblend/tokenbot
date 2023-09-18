open Fun.Let_syntax

exception HttpNotOk of Cohttp.Response.t

module J = Yojson.Safe
module H = Cohttp_lwt_unix.Client
module R = Cohttp.Response
module B = Cohttp_lwt.Body

let get_json ~uri ~headers =
  let* res, body = H.get uri ~headers in
  match R.status res with
  | `OK ->
      let* body = B.to_string body in
      let json = J.from_string body in
      Lwt.return (Ok json)
  | _ -> Lwt.return_error (HttpNotOk res)

let post_json ~uri ~headers ~json =
  let data = J.to_string json in
  let body = B.of_string data in
  let* res, body = H.post uri ~headers ~body in
  match R.status res with
  | `OK ->
      let* body = B.to_string body in
      let json = J.from_string body in
      Lwt.return (Ok json)
  | _ -> Lwt.return_error (HttpNotOk res)

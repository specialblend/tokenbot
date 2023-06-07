open Cohttp
open Cohttp_lwt
open Cohttp_lwt_unix
open Fun
open Lwt

exception HttpResponse of Response.t

let expect_ok (res, body) =
  match Response.status res with
  | `OK -> Ok body
  | _ -> Error (HttpResponse res)

let uri ~params url =
  let u = Uri.of_string url in
  Uri.add_query_params u params

let fetch ?(params = []) ?(headers = []) url =
  let uri' = uri ~params url in
  let headers = Header.of_list headers in
  let* res, body = Client.get ~headers uri' in
  let* body = Body.to_string body in
  return (expect_ok (res, body))

let post ?(params = []) ?(headers = []) ~body url =
  let uri' = uri ~params url in
  let headers = Header.of_list headers in
  let* res, body = Client.post ~headers ~body uri' in
  let* body = Body.to_string body in
  return (expect_ok (res, body))

let fetch_json ?params ?headers url =
  let* res = fetch ?params ?headers url in
  return (Result.map Json.from_string res)

let post_json ?params ?headers ~json url =
  let data = Yojson.Safe.to_string json in
  let body = Body.of_string data in
  let* res = post ?params ?headers ~body url in
  return (Result.map Json.from_string res)
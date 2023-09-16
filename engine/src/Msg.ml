open Contract

module Msg : Msg = struct
  type id
  type ts
  type t

  let id _ : id = assert false
  let text _ : long_text = assert false
  let timestamp _ : ts = assert false
end

include Msg

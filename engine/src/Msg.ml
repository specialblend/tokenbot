open Contract

module Msg : MSG = struct
  type id
  type timestamp
  type t

  let id _ : id = assert false
  let text _ : long_text = assert false
  let timestamp _ : timestamp = assert false
end

include Msg

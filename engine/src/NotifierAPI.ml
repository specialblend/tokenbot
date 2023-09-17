open Contract

module NotifierAPI : NotifierAPI = struct
  type t
  type 'a io

  module Thanks = Thanks

  let notify _ = assert false
end

include NotifierAPI

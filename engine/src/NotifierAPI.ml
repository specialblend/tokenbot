open Contract

module NotifierAPI : NotifierAPI = struct
  type t

  module Thanks = Thanks

  let notify _ = assert false
end

include NotifierAPI

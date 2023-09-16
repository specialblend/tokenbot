open Contract

module Engine : Engine = struct
  type 'a io

  module Msg = Msg
  module Item = Item
  module Player = Player
  module Txn = Txn
  module Participant = Participant
  module Thanks = Thanks
  module ThanksDB = ThanksDB
  module PlayerDB = PlayerDB

  let construct _ = assert false
  let collect _ _ = assert false
  let exchange _ _ = assert false
  let distribute _ _ = assert false
  let publish _ = assert false
  let notify _ = assert false
end

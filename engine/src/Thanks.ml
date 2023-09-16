open Contract

module Thanks : Thanks = struct
  module Msg = Msg
  module Player = Player
  module Token = Token
  module Txn = Txn

  type id = Msg.t
  type ts = Msg.ts

  type participant =
    | Sender of Player.t
    | Recipient of Player.t

  type t = {
    id: id;
    timestamp: ts;
    tokens: token list;
    msg: Msg.t;
    participants: participant list;
    sender: Player.t;
    recipients: Player.t list;
    txns: Txn.t list;
  }
  [@@deriving fields]
end

include Thanks

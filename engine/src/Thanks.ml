open Contract

module Thanks : Thanks = struct
  module Msg = Msg
  module Participant = Participant
  module Player = Player
  module Token = Token
  module Txn = Txn

  module Summary = struct
    type t
  end

  type id = Msg.t
  type timestamp = Msg.ts
  type summary = Summary.t

  type t = {
    id: id;
    timestamp: timestamp;
    tokens: token list;
    msg: Msg.t;
    participants: Participant.t list;
    sender: Player.t;
    recipients: Player.t list;
    txns: Txn.t list;
    summary: Summary.t;
  }
  [@@deriving fields]
end

include Thanks

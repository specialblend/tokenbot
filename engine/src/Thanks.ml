open Contract

module Thanks : THANKS = struct
  module Msg = Slack.Msg
  module Player = Player
  module Token = Token
  module Deposit = Deposit

  type id = string
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
    deposits: Deposit.t list;
  }
  [@@deriving fields]
end

include Thanks

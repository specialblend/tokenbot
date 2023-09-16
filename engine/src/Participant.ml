open Contract

module Participant : Participant = struct
  module Player = Player

  type t =
    | Sender of Player.t
    | Recipient of Player.t

  let sender_of player = Sender player
  let recipient_of player = Recipient player

  let player = function
    | Sender player -> player
    | Recipient player -> player

  let is_sender = function
    | Sender _ -> true
    | _ -> false

  let is_recipient = function
    | Recipient _ -> true
    | _ -> false
end

include Participant

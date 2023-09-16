(*  *)

type emoji = Emoji of string
type short_text = ShortText of string
type long_text = LongText of string
type tz_offset = Seconds of int

module type NATURAL = sig
  type t

  val ( + ) : t -> t -> t
  val ( - ) : t -> t -> t option
  val ( -! ) : t -> t -> t

  (*  *)
  val make : int -> t option
end

module type PERCENTAGE = sig
  include NATURAL
end

module type DURATION = sig
  module Nat : NATURAL

  type t =
    | Seconds of Nat.t
    | Minutes of Nat.t
    | Hours of Nat.t
end

module type QTY = sig
  type t = Qty of int
end

module type TOKEN = sig
  type t

  val eq : t -> t -> bool
  val make : string -> t option
end

module type MSG = sig
  type t
  type id
  type timestamp

  val id : t -> id
  val timestamp : t -> timestamp
  val text : t -> long_text
end

module type ITEM = sig
  type t
  type token
  type qty

  val token : t -> token
  val qty : t -> qty

  (*  *)
  val make : token -> qty -> t
  val map_qty : (qty -> qty) -> t -> t

  (*  *)
  val stack : t list -> t -> t list
end

module type COOLDOWN = sig
  type t

  module Token : TOKEN
  module Duration : DURATION

  val token : t -> Token.t
  val duration : t -> Duration.t
end

module type PLAYER = sig
  type t
  type id
  type summary

  module Nat : NATURAL
  module Item : ITEM
  module Cooldown : COOLDOWN
  module Percentage : PERCENTAGE

  val id : t -> id
  val name : t -> short_text
  val base_score : t -> Nat.t
  val bonus_score : t -> Nat.t
  val luck : t -> Percentage.t
  val inventory : t -> Item.t list
  val cooldowns : t -> Cooldown.t list
  val is_bot : t -> bool

  (*  *)
  val summary : t -> summary
end

module type PARTICIPANT = sig
  module Player : PLAYER

  type t =
    | Sender of Player.t
    | Recipient of Player.t

  val player : t -> Player.t

  (*  *)
  val is_sender : t -> bool
  val is_recipient : t -> bool
end

module type TXN = sig
  type t

  module Participant : PARTICIPANT
  module Item : ITEM
  module Cooldown : COOLDOWN

  val participant : t -> Participant.t
  val item : t -> Item.t
  val cooldown : t -> Cooldown.t option
  val about : t -> short_text option
end

module type THANKS = sig
  type t
  type id
  type summary
  type timestamp

  module Msg : MSG with type timestamp = timestamp
  module Participant : PARTICIPANT
  module Player : PLAYER
  module Token : TOKEN
  module Txn : TXN

  val id : t -> id
  val timestamp : t -> timestamp
  val msg : t -> Msg.t
  val participants : t -> Participant.t list
  val sender : t -> Player.t
  val recipients : t -> Player.t list
  val tokens : t -> Token.t list
  val txns : t -> Txn.t list
  val summary : t -> summary
end

module type THANKS_DB = sig
  type 'a io
  type t

  module Thanks : THANKS

  val get_thanks : t -> Thanks.id -> Thanks.t io
  val put_thanks : t -> Thanks.t -> unit io
end

module type PLAYER_DB = sig
  type 'a io
  type t

  module Player : PLAYER

  val get_player : t -> Player.t -> Player.t io
  val put_player : t -> Player.t -> unit io
end

module type ENGINE = sig
  type 'a io

  (*  *)
  module Msg : MSG

  (*  *)
  module Item : ITEM
  module Player : PLAYER

  (*  *)
  module Txn : TXN
  module Participant : PARTICIPANT

  (*  *)
  module Thanks : THANKS

  (*  *)
  module ThanksDB : THANKS_DB with module Thanks = Thanks
  module PlayerDB : PLAYER_DB with module Player = Player

  type collected = Collected of Txn.t list
  type distributed = Distributed of Participant.t list
  type exchanged = Exchanged of Participant.t list
  type published = Published of Thanks.t
  type notified = Notified of Thanks.t

  (*  *)
  type collect_rule = Thanks.t -> Txn.t list -> Txn.t list
  type exchange_rule = Item.t -> Txn.t list

  val construct : Msg.t -> Thanks.t io
  val collect : collect_rule list -> Thanks.t -> collected
  val exchange : exchange_rule list -> Participant.t list -> exchanged
  val distribute : Participant.t list -> Txn.t list -> distributed
  val publish : Thanks.t -> published io
  val notify : Thanks.t -> notified io
end

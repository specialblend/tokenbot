(*  *)
type nat = Natural of int
type percent = Percent of int
type emoji = Emoji of string
type short_text = ShortText of string
type long_text = LongText of string
type tz_offset = Seconds of int

type duration =
  | Seconds of nat
  | Minutes of nat
  | Hours of nat

(*  *)
type token = Token of emoji
type qty = Qty of nat
type stat = Stat of percent

module type MSG = sig
  type t
  type id
  type timestamp

  val timestamp : t -> timestamp
  val text : t -> long_text
end

module type ITEM = sig
  type t

  val token : t -> token
  val qty : t -> qty
end

module type COOLDOWN = sig
  type t

  val token : t -> token
  val duration : t -> duration
end

module type PARTICIPANT = sig
  type t
  type player

  val player : t -> bool
  val is_sender : t -> bool
  val is_recipient : t -> bool
  val is_player : t -> player -> bool
end

module type TXN = sig
  type t
  type participant
  type item
  type about
  type cooldown

  val participant : t -> participant
  val item : t -> item
  val about : t -> about option
  val cooldown : t -> cooldown option
end

module type PLAYER = sig
  type t
  type id
  type summary
  type item
  type cooldown

  val id : t -> id
  val name : t -> short_text
  val base_score : t -> nat
  val bonus_score : t -> nat
  val luck : t -> stat
  val inventory : t -> item list
  val cooldowns : t -> cooldown list
  val is_bot : t -> bool

  (*  *)
  val summary : t -> summary
end

module type THANKS = sig
  type t
  type id
  type msg
  type summary
  type timestamp
  type participant
  type sender
  type recipient
  type txn

  val id : t -> id
  val timestamp : t -> timestamp
  val msg : t -> msg
  val participants : t -> participant list
  val sender : t -> sender
  val recipients : t -> recipient list
  val tokens : t -> token list
  val txns : t -> txn list
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

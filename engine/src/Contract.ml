(*  *)
type 'a promise = 'a Lwt.t
type 'a fallible = ('a, exn) result
type 'a io = 'a fallible promise

(*  *)
type nat = Natural of int
type percent = Percent of int
type emoji = Emoji of string
type short_text = ShortText of string
type tz_offset = Seconds of int

(*  *)
type token = Token of emoji
type qty = Qty of nat
type stat = Stat of percent

(*  *)
module type ITEM = sig
  type t

  val token : t -> token
  val qty : t -> qty
end

module type COOLDOWN = sig
  type t
  type token
  type duration

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

  val participant : t -> participant
end

module type PLAYER = sig
  type t
  type id
  type summary
  type item

  val id : t -> id
  val name : t -> short_text
  val base_score : t -> nat
  val bonus_score : t -> nat
  val luck : t -> stat
  val inventory : t -> item list
  val cooldowns : t -> item list
  val is_bot : t -> bool

  (*  *)
  val summary : t -> summary
end

module type THANKS = sig
  type t
  type msg
  type msg_id
  type timestamp
  type participant
  type sender
  type recipient
  type summary
  type txn

  val id : t -> msg_id
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
  type t
  type thanks
  type msg_id

  val get_thanks : t -> msg_id -> thanks io
  val put_thanks : t -> thanks -> unit io
end

module type PLAYER_DB = sig
  type t
  type player_id
  type player
  type thanks

  val get_player : t -> player_id -> thanks io
  val put_player : t -> player -> unit io
end

module type DB = sig
  type t
  type player
  type player_id
  type msg_id
  type thanks

  module type THANKS_DB =
    THANKS_DB with type thanks = thanks and type msg_id = msg_id

  module type PLAYER_DB =
    PLAYER_DB with type player = player and type player_id = player_id
end

module type ENGINE = sig
  module DB = DB

  type t
  type msg
  type thanks
  type item
  type sender
  type recipient

  type participant =
    | Sender of sender
    | Recipient of recipient

  type txn =
    | Give of participant * item
    | Take of participant * item
    | Forfeit of participant
    | Roll of participant * qty

  type collect_rule = participant list -> txn list -> txn list
  type exchange_rule = item -> txn list

  val construct : msg -> thanks io
  val collect : collect_rule list -> participant list -> txn list
  val exchange : exchange_rule list -> participant list -> txn list
  val distribute : participant list -> txn list -> participant list
  val report : thanks -> unit io
  val run : msg -> thanks io
end

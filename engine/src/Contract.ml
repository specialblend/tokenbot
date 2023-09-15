(*  *)
type nat = Natural of int
type percent = Percent of int
type emoji = Emoji of string
type short_text = ShortText of string
type tz_offset = Seconds of int

type duration =
  | Seconds of nat
  | Minutes of nat
  | Hours of nat

(*  *)
type token = Token of emoji
type qty = Qty of nat
type stat = Stat of percent

module type ENGINE = sig
  (*  *)
  type 'a io

  (*  *)
  type timestamp

  (*  *)
  type msg_id
  type thanks_id
  type player_id

  (*  *)
  type msg
  type thanks
  type player

  (*  *)
  type thanks_summary
  type player_summary

  (*  *)
  type item
  type cooldown

  (*  *)
  type sender = player
  type recipient = player

  type participant =
    | Sender of sender
    | Recipient of recipient

  type txn =
    | Give of participant * item
    | Take of participant * item
    | Forfeit of participant
    | Roll of participant * qty

  module type ITEM = sig
    type t = item

    val token : t -> token
    val qty : t -> qty
  end

  module type COOLDOWN = sig
    type t = cooldown

    val token : t -> token
    val duration : t -> duration
  end

  module type PARTICIPANT = sig
    type t = participant

    val player : t -> bool
    val is_sender : t -> bool
    val is_recipient : t -> bool
    val is_player : t -> player -> bool
  end

  module type TXN = sig
    type t = txn

    val participant : t -> participant
  end

  module type PLAYER = sig
    type t = player
    type summary = player_summary

    val id : t -> player_id
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
    type t = thanks
    type summary = thanks_summary

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

    val get_thanks : t -> msg_id -> thanks io
    val put_thanks : t -> thanks -> unit io
  end

  module type PLAYER_DB = sig
    type t

    val get_player : t -> player_id -> thanks io
    val put_player : t -> player -> unit io
  end

  module type DB = sig
    type t

    module type THANKS_DB = THANKS_DB
    module type PLAYER_DB = PLAYER_DB
  end

  type t
  type collect_rule = participant list -> txn list -> txn list
  type exchange_rule = item -> txn list

  val construct : msg -> thanks io
  val collect : collect_rule list -> participant list -> txn list
  val exchange : exchange_rule list -> participant list -> txn list
  val distribute : participant list -> txn list -> participant list
  val report : thanks -> unit io
  val run : msg -> thanks io
end

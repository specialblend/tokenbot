type natural = Nat of int
type percent = Percent of int
type emoji = Emoji of string
type short_text = ShortText of string

(*  *)
type token = Token of emoji
type qty = Qty of natural
type stat = Stat of percent

(*  *)
type item

(*  *)
type duration
type cooldown

(*  *)
type player
type player_id

(*  *)
type msg_id
type sender
type recipient
type timestamp

type participant =
  | Sender of sender
  | Recipient of recipient

type txn =
  | Give of participant * item
  | Take of participant * item
  | Forfeit of participant
  | Roll of participant * qty

type player_summary
type thanks
type thanks_summary
type msg

(*  *)
type 'a promise = 'a Lwt.t
type 'a fallible = ('a, exn) result
type 'a io = 'a fallible promise

(*  *)
type collect_rule = participant -> txn list -> txn list
type exchange_rule = item -> txn list
type collector = collect_rule list -> participant list -> txn list
type exchanger = exchange_rule list -> participant list -> txn list
type distributor = participant list -> txn list -> participant list
type reporter = thanks -> unit
type engine = msg -> (thanks, exn) result promise

(*  *)
module type Item = sig
  type t = item

  val token : t -> token
  val qty : t -> qty
end

module type Cooldown = sig
  type t = cooldown

  val token : t -> token
  val duration : t -> duration
end

module type Participant = sig
  type t = participant

  val player : t -> bool
  val is_sender : t -> bool
  val is_recipient : t -> bool
  val is_player : t -> player -> bool
end

module type Txn = sig
  type t

  val participant : t -> participant
end

module type Player = sig
  type t = player

  val id : t -> player_id
  val name : t -> short_text
  val base_score : t -> natural
  val bonus_score : t -> natural
  val luck : t -> stat
  val inventory : t -> item list
  val cooldown : t -> cooldown list
  val summary : t -> player_summary
end

module type Thanks = sig
  type t = thanks

  val id : t -> msg_id
  val timestamp : t -> timestamp
  val msg : t -> msg
  val participants : t -> participant list
  val sender : t -> sender
  val recipients : t -> recipient list
  val tokens : t -> token list
  val txns : t -> txn list
  val summary : t -> thanks_summary
end

module type ThanksDB = sig
  type t

  val get_thanks : t -> msg_id -> thanks io
  val put_thanks : t -> thanks -> unit io
end

module type PlayerDB = sig
  type t

  val get_player : t -> player_id -> thanks io
  val put_player : t -> player -> unit io
end

module type DB = sig
  module ThanksDB = ThanksDB
  module PlayerDB = PlayerDB
end

module type Engine = sig
  module DB = DB

  type t

  val collect : t -> collector
  val exchange : t -> exchanger
  val distribute : t -> distributor
  val report : t -> reporter
  val run : t -> engine
end

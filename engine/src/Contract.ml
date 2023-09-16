(*  *)
type nat = System.Nat.t
type short_text = Short of string
type long_text = Long of string
type tz_offset = Seconds of int

(*  *)
type 'a fallible = ('a, exn) result
type 'a promise
type 'a io = 'a fallible promise

(*  *)
type qty = Qty of nat
type token = Token of string
type duration = Seconds of nat

module type Msg = sig
  type t
  type id
  type ts

  val id : t -> id
  val timestamp : t -> ts
  val text : t -> long_text
end

module type Item = sig
  type t

  val token : t -> token
  val qty : t -> qty

  (*  *)
  val make : token -> qty -> t
  val map_qty : (qty -> qty) -> t -> t

  (*  *)
  val stack : t list -> t -> t list
end

module type Cooldown = sig
  type t

  val token : t -> token
  val duration : t -> duration
end

module type Player = sig
  type t
  type id

  module Item : Item
  module Cooldown : Cooldown

  val id : t -> id
  val name : t -> short_text
  val base_score : t -> nat
  val bonus_score : t -> nat
  val luck : t -> nat
  val inventory : t -> Item.t list
  val cooldowns : t -> Cooldown.t list
  val is_bot : t -> bool
end

module type PlayerSummary = sig
  type t
  type id

  module Player : Player

  val id : t -> id
  val name : t -> short_text
  val of_player : Player.t -> t
end

module type Txn = sig
  type t

  module Player : Player
  module Item : Item
  module Cooldown : Cooldown

  val player : t -> Player.t
  val item : t -> Item.t
  val cooldown : t -> Cooldown.t option
  val about : t -> short_text option
end

module type TxnSummary = sig
  type t

  module Txn : Txn
  module Player : PlayerSummary

  val player : t -> Player.t
  val item : t -> Txn.Item.t
  val of_txn : Txn.t -> t
end

module type Thanks = sig
  type t
  type id

  module Msg : Msg
  module Player : Player
  module Txn : Txn

  type participant =
    | Sender of Player.t
    | Recipient of Player.t

  val id : t -> id
  val tokens : t -> token list
  val timestamp : t -> Msg.ts
  val msg : t -> Msg.t
  val sender : t -> Player.t
  val recipients : t -> Player.t list
  val txns : t -> Txn.t list
  val participants : t -> participant list
end

module type ThanksSummary = sig
  type t

  module Thanks : Thanks
  module Player : PlayerSummary
  module Txn : TxnSummary

  val id : t -> Thanks.id
  val timestamp : t -> Thanks.Msg.ts
  val text : t -> long_text
  val sender : t -> Player.t
  val grouped_txns : t -> Player.t * Txn.t list
  val of_thanks : Thanks.t -> t
end

module type ThanksDB = sig
  type t

  module Thanks : Thanks

  val get_thanks : t -> Thanks.id -> Thanks.t io
  val put_thanks : t -> Thanks.t -> unit io
end

module type PlayerDB = sig
  type t

  module Player : Player

  val get_player : t -> Player.t -> Player.t io
  val put_player : t -> Player.t -> unit io
end

module type NotifierAPI = sig
  type t

  module Thanks : Thanks

  val notify : Thanks.t -> unit io
end

module type Engine = sig
  module Thanks : Thanks
  module ThanksDB : ThanksDB
  module PlayerDB : PlayerDB
  module NotifierAPI : NotifierAPI

  type collector_rule = Thanks.t -> Thanks.Txn.t list -> Thanks.Txn.t list
  type exchange_rule = Thanks.Txn.Item.t -> Thanks.Txn.t list
  type sender = Sender of Thanks.Player.t
  type recipient = Recipient of Thanks.Player.t

  (*  *)
  type received = Received of Thanks.Msg.t * Thanks.t
  type collected = Collected of Thanks.Txn.t list
  type distributed = Distributed of Thanks.Player.t list
  type exchanged = Exchanged of Thanks.Player.t list
  type published = Published of Thanks.t
  type notified = Notified of Thanks.t

  (*  *)
  type receptionist = Thanks.Msg.t -> Thanks.t io
  type collector = collector_rule list -> Thanks.t -> collected
  type distributor = collected -> Thanks.t -> distributed
  type exchanger = exchange_rule list -> distributed -> Thanks.t -> exchanged
  type publisher = exchanged -> Thanks.t -> published io
  type notifier = published -> notified io

  val receive : receptionist
  val collect : collector
  val distribute : distributor
  val exchange : exchanger
  val publish : publisher
  val notify : notifier
end

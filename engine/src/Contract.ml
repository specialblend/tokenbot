(*  *)
type nat = System.Nat.t
type short_text = Short of string
type long_text = Long of string
type tz_offset = Seconds of int

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
  type summary

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
  val summary : t -> summary
end

module type Participant = sig
  module Player : Player

  type t

  val sender_of : Player.t -> t
  val recipient_of : Player.t -> t
  val player : t -> Player.t
  val is_sender : t -> bool
  val is_recipient : t -> bool
end

module type Txn = sig
  type t

  module Participant : Participant
  module Item : Item
  module Cooldown : Cooldown

  val participant : t -> Participant.t
  val item : t -> Item.t
  val cooldown : t -> Cooldown.t option
  val about : t -> short_text option
end

module type Thanks = sig
  type t
  type id
  type summary

  module Msg : Msg
  module Participant : Participant
  module Player : Player
  module Txn : Txn

  val id : t -> id
  val tokens : t -> token list
  val timestamp : t -> Msg.ts
  val msg : t -> Msg.t
  val participants : t -> Participant.t list
  val sender : t -> Player.t
  val recipients : t -> Player.t list
  val txns : t -> Txn.t list
  val summary : t -> summary
end

module type ThanksDB = sig
  type 'a io
  type t

  module Thanks : Thanks

  val get_thanks : t -> Thanks.id -> Thanks.t io
  val put_thanks : t -> Thanks.t -> unit io
end

module type PlayerDB = sig
  type 'a io
  type t

  module Player : Player

  val get_player : t -> Player.t -> Player.t io
  val put_player : t -> Player.t -> unit io
end

type ('thx, 'txn) collect_rule = 'thx -> 'txn list -> 'txn list
type ('item, 'txn) exchange_rule = 'item -> 'txn list
type 'txn collected = Collected of 'txn list
type 'part distributed = Distributed of 'part list
type 'part exchanged = Exchanged of 'part list
type 'thx published = Published of 'thx
type 'thx notified = Notified of 'thx

module type Engine = sig
  type 'a io

  module Msg : Msg
  module Item : Item
  module Player : Player
  module Txn : Txn
  module Participant : Participant
  module Thanks : Thanks

  (*  *)
  module ThanksDB : ThanksDB
  module PlayerDB : PlayerDB

  (*  *)

  val construct : Msg.t -> Thanks.t io

  val collect :
    (Thanks.t, Txn.t) collect_rule list -> Thanks.t -> Txn.t collected

  val exchange :
    (Item.t, Txn.t) exchange_rule list ->
    Participant.t list ->
    Participant.t exchanged

  val distribute : Participant.t list -> Txn.t list -> Participant.t distributed
  val publish : Thanks.t -> Thanks.t published io
  val notify : Thanks.t -> Thanks.t notified io
end

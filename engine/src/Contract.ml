type tz_offset = Seconds of int
type token = Token of string
type qty = Qty of int

type duration =
  | Seconds of int
  | Minutes of int
  | Hours of int

module type TIMESTAMP = sig
  type t
end

module type USER = sig
  type t
  type id

  val id : t -> id
  val name : t -> string
  val is_bot : t -> bool
  val tz_offset : t -> int
end

module type CHANNEL = sig
  type t
  type id
end

module type THREAD = sig
  type t
end

module type MSG = sig
  module Ts : TIMESTAMP
  module Usr : USER
  module Chan : CHANNEL
  module Thr : THREAD

  type t
  type id
  type txt

  val id : t -> id
  val txt : t -> string
  val ts : t -> Ts.t
  val chan : t -> Chan.t
  val usr : t -> Usr.id
  val thr : t -> Thr.t
end

module type LOOKUP_USER = sig
  module Usr : USER

  type 'a promise

  val lookup : Usr.id -> Usr.t option promise
end

module type POST_MESSAGE = sig
  module Chan : CHANNEL
  module Thr : THREAD

  type 'a promise

  val post : chan:Chan.t -> ?thread:Thr.t -> txt:string -> unit promise
end

module type ITEM = sig
  type t

  val token : t -> token
  val qty : t -> qty
  val make : token -> qty -> t
  val map_qty : (qty -> qty) -> t -> t
  val stack : t list -> t -> t list
end

module type COOLDOWN = sig
  type t

  val token : t -> token
  val duration : t -> duration
  val stack : t list -> t -> t list
end

module type PLAYER = sig
  type t
  type id = string

  module Item : ITEM
  module Cooldown : COOLDOWN

  val id : t -> id
  val name : t -> string
  val base_score : t -> int
  val bonus_score : t -> int
  val luck : t -> int
  val inventory : t -> Item.t list
  val cooldowns : t -> Cooldown.t list
  val is_bot : t -> bool
end

module type PLAYER_SUMMARY = sig
  module Player : PLAYER

  type t
  type id = Player.id

  val id : t -> id
  val name : t -> string
  val of_player : Player.t -> t
end

module type DEPOSIT = sig
  type t

  module Player : PLAYER_SUMMARY
  module Item : ITEM
  module Cooldown : COOLDOWN

  val player : t -> Player.t
  val item : t -> Item.t
  val cooldown : t -> Cooldown.t option
  val about : t -> string option
end

module type THANKS = sig
  module Msg : MSG
  module Player : PLAYER
  module Deposit : DEPOSIT

  type t
  type id = string

  type participant =
    | Sender of Player.t
    | Recipient of Player.t

  val id : t -> id
  val tokens : t -> token list
  val msg : t -> Msg.t
  val sender : t -> Player.t
  val recipients : t -> Player.t list
  val deposits : t -> Deposit.t list
  val participants : t -> participant list
end

module type THANKS_DB = sig
  module Thanks : THANKS

  type t
  type 'a io

  val get : t -> Thanks.id -> Thanks.t io
  val put : t -> Thanks.t -> unit io
end

module type PLAYER_DB = sig
  module Player : PLAYER

  type t
  type 'a io

  val get : t -> Player.id -> Player.t io
  val put : t -> Player.t -> unit io
end

module type Engine = sig
  type 'a io

  module Item : ITEM
  module Msg : MSG
  module Deposit : DEPOSIT
  module Player : PLAYER

  (*  *)
  module ThanksDB : THANKS_DB
  module PlayerDB : PLAYER_DB

  type sender = Sender of Player.t
  type recipient = Recipient of Player.t

  (*  *)
  type received = Received of Msg.t
  type scanned = Scanned of received * sender * recipient list
  type collected = Collected of scanned * Deposit.t list
  type distributed = Distributed of collected * (Player.t * Item.t list) list
  type exchanged = Exchanged of distributed * Deposit.t list
  type settled = Settled of exchanged * distributed
  type published = Published of settled
  type notified = Notified of published

  val run :
    Msg.t ->
    received ->
    scanned io ->
    collected ->
    distributed ->
    exchanged ->
    settled ->
    published io ->
    notified io
end

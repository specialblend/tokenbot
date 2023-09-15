type token
type qty
type item
type duration
type cooldown
type score
type luck
type player

type participant =
  | Sender of player
  | Recipient of player

type deposit
type thanks
type msg

(**)
type collection_rule = thanks -> deposit list -> deposit list
type exchange_rule = item list -> deposit list
type collector = collection_rule list -> thanks -> deposit list
type distributor = player list

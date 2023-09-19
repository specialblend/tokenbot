open Fun

module Deposit = struct
  module PlayerSummary = Player.Summary
  module Item = Item
  module Cooldown = Cooldown

  type t = {
    item: Item.t;
    player: PlayerSummary.t;
    cooldown: int option;
    about: string option;
  }
  [@@deriving fields, yojson]

  let token = item >> Item.token
  let qty = item >> Item.qty
  let player_id = player >> PlayerSummary.id

  let give ?(qty = 1) ?about ?cooldown player emoji =
    {
      item = Item.make Item.(Token emoji) qty;
      player = PlayerSummary.of_player player;
      cooldown = Option.map Cooldown.seconds cooldown;
      about;
    }
end

include Deposit

export type { User } from "@slack/web-api/dist/response/UsersInfoResponse";

export type PlayerId = string;
export type Token = string;
export type Qty = number;

export type Msg = {
  channel: string;
  client_msg_id: string;
  event_ts: string;
  team: string;
  text: string;
  thread_ts: string | null;
  ts: string;
  user: PlayerId;
};

export type Item = [Token, Qty];

export type Player = {
  id: string;
  name: string;
  tz_offset: number;
  items: Item[];
  cooldowns: Item[];
  score: {
    base: number;
    bonus: number;
    total: number;
  };
  highscore: number;
  luck: number;
  is_bot: boolean;
};

export type PartialPlayer = Pick<Player, "id" | "name">;

export type Deposit = {
  player: {
    id: string;
    name: string;
  };
  item: Item;
  about: string;
  cooldown: number | null;
};

export type PlayerDeposits = [PartialPlayer, Deposit[]];

export type Thanks = {
  id: string;
  msg: Msg;
  sender: PartialPlayer;
  tokens: string[];
  player_deposits: PlayerDeposits[];
};

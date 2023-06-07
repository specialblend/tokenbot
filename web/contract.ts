export type Me = {
  id: string;
  team_id: string;
  real_name: string;
  name: string;
  is_admin: boolean;
  is_owner: boolean;
  is_primary_owner: boolean;
  is_bot: boolean;
};

export type PlayerId = string;
export type Token = string;
export type Qty = number;

export interface Profile {
  title: string;
  phone: string;
  skype: string;
  real_name: string;
  real_name_normalized: string;
  display_name: string;
  display_name_normalized: string;
  fields?: string | null;
  status_text: string;
  status_emoji: string;
  status_emoji_display_info: string[];
  status_expiration: number;
  avatar_hash: string;
  first_name: string;
  last_name: string;
  image_24: string;
  image_32: string;
  image_48: string;
  image_72: string;
  image_192: string;
  image_512: string;
  status_text_canonical: string;
  team: string;
}

export interface User {
  id: PlayerId;
  team_id: string;
  name: string;
  deleted: boolean;
  color: string;
  real_name: string;
  tz: string;
  tz_label: string;
  tz_offset: number;
  is_admin: boolean;
  is_owner: boolean;
  is_primary_owner: boolean;
  is_restricted: boolean;
  is_ultra_restricted: boolean;
  is_bot: boolean;
  is_app_user: boolean;
  updated: number;
  is_email_confirmed: boolean;
  who_can_share_contact_card: string;
  profile: Profile;
}

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

export type Deposit = {
  about: string;
  target: PlayerId;
  token: Token;
  qty: Qty;
};

export type Txn = [PlayerId, Deposit[]];

export type Thanks = {
  text: string;
  sender: PlayerId;
  recipients: PlayerId[];
  msg: Msg;
  txns: Txn[];
  diffs: [PlayerId, number][];
};

export type Stats = {
  greed: number;
  luck: number;
  bonus: number;
};

export type Item = [Token, Qty];

export interface Player {
  id: string;
  score: number;
  highscore: number;
  inventory: Item[];
  stats: Stats;
}

export type Feed = Thanks[];

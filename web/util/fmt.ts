import type { Me, Thanks, User } from "~/contract";

export let timestamp = (thx: Thanks) => new Date(parseFloat(thx.msg.ts) * 1000);

export let fmtUserName = (id: string, user?: User) =>
  user?.profile.display_name || user?.real_name || user?.name || id;

export let pickMe = (user: User): Me => {
  let {
    id,
    name,
    real_name,
    team_id,
    is_admin,
    is_owner,
    is_primary_owner,
    is_bot,
  } = user;
  return {
    id,
    name,
    real_name,
    team_id,
    is_admin,
    is_owner,
    is_primary_owner,
    is_bot,
  };
};

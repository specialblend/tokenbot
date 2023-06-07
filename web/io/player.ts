import type { Player } from "~/contract";

import { getServerSession } from "next-auth";

import { getPlayer } from "~/io/engine";
import { isAppSession } from "~/auth/session";
import { authOptions } from "~/auth/config";

export async function getMyPlayer(): Promise<Player | undefined> {
  let session = await getServerSession(authOptions);
  if (isAppSession(session)) {
    return getPlayer(session.me.id);
  }
}

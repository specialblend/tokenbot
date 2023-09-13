import type { Player } from "~/contract";

import { getServerSession } from "next-auth";

import { getPlayer } from "~/io/engine";
import { isAppSession } from "~/auth/session";
import { authOptions } from "~/auth/config";

export async function getMyPlayer(): Promise<Player | undefined> {
  const session = await getServerSession(authOptions);
  if (isAppSession(session) && session.me.id) return getPlayer(session.me.id);
}

console.debug({ pid: process.pid }, "io/player.ts", __filename);

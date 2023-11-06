import type { Player } from "~/contract";
import type { NextApiRequest, NextApiResponse } from "next";

import { getServerSession } from "next-auth";

import { getPlayer } from "~/io/engine";
import { isAppSession } from "~/auth/session";
import { authOptions } from "~/auth/config";

export async function getMyPlayer(
  req: NextApiRequest,
  res: NextApiResponse,
): Promise<Player | undefined> {
  const session = await getServerSession(req, res, authOptions);
  if (isAppSession(session) && session.me.id) return getPlayer(session.me.id);
}

console.debug({ pid: process.pid }, "io/player.ts", __filename);

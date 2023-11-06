import type { NextApiRequest, NextApiResponse } from "next";

import { getScoreboard } from "~/io/engine";

export default async function HighScore(
  req: NextApiRequest,
  res: NextApiResponse,
) {
  const scoreboard = await getScoreboard(25);
  res.json(scoreboard);
}

import type { NextApiRequest, NextApiResponse } from "next";

import { getHighscoreBoard } from "~/io/engine";

export default async function HighScore(
  req: NextApiRequest,
  res: NextApiResponse,
) {
  const scoreboard = await getHighscoreBoard(25);
  res.json(scoreboard);
}

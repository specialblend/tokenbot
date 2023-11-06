import type { NextApiRequest, NextApiResponse } from "next";

import { getMyPlayer } from "~/io/player";

export default async function Me(req: NextApiRequest, res: NextApiResponse) {
  const player = await getMyPlayer(req, res);
  res.json(player);
}

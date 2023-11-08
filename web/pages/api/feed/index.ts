import type { NextApiRequest, NextApiResponse } from "next";

import { getFeed } from "~/io/engine";

export default async function feed(req: NextApiRequest, res: NextApiResponse) {
  const feed = await getFeed(32);
  res.json(feed);
}

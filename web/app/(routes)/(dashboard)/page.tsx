"use server";

/* eslint-disable @typescript-eslint/ban-ts-comment */

import { getMyPlayer } from "~/io/player";
import { getFeed, getScoreboard } from "~/io/engine";
import { SplitFeedView } from "~/app/components/SplitFeedView";
import { Scoreboard } from "~/app/components/Scoreboard/Scoreboard";
import { Placeholder } from "~/app/components/Placeholder";

let scoreboardSize = 10;
let feedSize = 25;

export default async function ScoreboardPage(
  _: never,
  f = { getScoreboard, getFeed, getMyPlayer },
) {
  let [players, feed, me] = await Promise.all([
    f.getScoreboard({ useHighscore: true, count: scoreboardSize }),
    f.getFeed(feedSize),
    f.getMyPlayer(),
  ]);
  if (feed.length) {
    return (
      <SplitFeedView feed={feed}>
        {/* @ts-ignore */}
        <Scoreboard me={me} players={players} useHighscore={false} />
      </SplitFeedView>
    );
  }
  if (players.length) {
    // @ts-ignore
    return <Scoreboard players={players} useHighscore={false} />;
  }
  return <Placeholder />;
}

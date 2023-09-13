"use server";

import { getMyPlayer } from "~/io/player";
import { getFeed, getScoreboard } from "~/io/engine";
import { SplitFeedView } from "~/app/components/SplitFeedView";
import { Scoreboard } from "~/app/components/Scoreboard/Scoreboard";
import { Placeholder } from "~/app/components/Placeholder";

const scoreboardSize = 10;
const feedSize = 25;

export default async function ScoreboardPage(
  _: never,
  f = { getScoreboard, getFeed, getMyPlayer },
) {
  const [players, feed, me] = await Promise.all([
    f.getScoreboard(scoreboardSize),
    f.getFeed(feedSize),
    f.getMyPlayer(),
  ]);
  if (feed.length) {
    return (
      <SplitFeedView feed={feed}>
        <Scoreboard me={me} players={players} useHighscore={false} />
      </SplitFeedView>
    );
  }
  if (players.length) {
    return <Scoreboard players={players} useHighscore={false} />;
  }
  return <Placeholder />;
}

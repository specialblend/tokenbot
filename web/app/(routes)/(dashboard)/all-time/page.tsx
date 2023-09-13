"use server";

import { getMyPlayer } from "~/io/player";
import { getFeed, getHighscoreBoard } from "~/io/engine";
import { SplitFeedView } from "~/app/components/SplitFeedView";
import { Scoreboard } from "~/app/components/Scoreboard/Scoreboard";
import { Placeholder } from "~/app/components/Placeholder";

const scoreboardSize = 10;
const feedSize = 25;

export default async function AllTimeScoreboardPage(
  _: never,
  f = { getHighscoreBoard, getFeed, getMyPlayer },
) {
  const [players, feed, me] = await Promise.all([
    f.getHighscoreBoard(scoreboardSize),
    f.getFeed(feedSize),
    f.getMyPlayer(),
  ]);

  if (feed.length) {
    return (
      <SplitFeedView feed={feed}>
        <Scoreboard me={me} players={players} useHighscore={true} />
      </SplitFeedView>
    );
  }
  if (players.length) {
    return <Scoreboard me={me} players={players} useHighscore={true} />;
  }
  return <Placeholder />;
}

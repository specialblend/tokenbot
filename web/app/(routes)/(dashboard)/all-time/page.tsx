"use client";

import type { Player, Thanks } from "~/contract";

import useSWR from "swr";

import { SplitFeedView } from "~/app/components/SplitFeedView";
import { Scoreboard } from "~/app/components/Scoreboard/Scoreboard";
import { Placeholder } from "~/app/components/Placeholder";

const fetcher = (url: string) => fetch(url).then((r) => r.json());
export default function AllTimeScoreboardPage(_: never) {
  const me = useSWR<Player>("/api/me", fetcher);
  const players = useSWR<Player[]>("/api/highscore", fetcher, {
    refreshInterval: 10000,
  });
  const feed = useSWR<Thanks[]>("/api/feed", fetcher, {
    refreshInterval: 10000,
  });

  if (feed.data && feed.data.length) {
    return (
      <SplitFeedView feed={feed.data}>
        <Scoreboard
          me={me.data}
          players={players.data ?? []}
          useHighscore={true}
        />
      </SplitFeedView>
    );
  }
  if (players.data && players.data.length) {
    return (
      <Scoreboard me={me.data} players={players.data} useHighscore={true} />
    );
  }
  return <Placeholder />;
}

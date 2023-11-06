"use client";

import type { Player, Thanks } from "~/contract";

import useSWR from "swr";

import { SplitFeedView } from "~/app/components/SplitFeedView";
import { Scoreboard } from "~/app/components/Scoreboard/Scoreboard";
import { Placeholder } from "~/app/components/Placeholder";

const fetcher = (url: string) => fetch(url).then((r) => r.json());

export default function ScoreboardPage(_: never) {
  const me = useSWR<Player>("/api/me", fetcher);
  const players = useSWR<Player[]>("/api/score", fetcher, {
    refreshInterval: 10000,
  });
  const feed = useSWR<Thanks[]>("/api/feed", fetcher, {
    refreshInterval: 10000,
  });

  console.log({
    me: me.data,
    players: players.data,
    feed: feed.data,
  });

  if (feed.data && feed.data.length) {
    return (
      <SplitFeedView feed={feed.data}>
        <Scoreboard
          me={me.data}
          players={players.data ?? []}
          useHighscore={false}
        />
      </SplitFeedView>
    );
  }
  if (players.data && players.data.length) {
    return <Scoreboard players={players.data} useHighscore={false} />;
  }
  return <Placeholder />;
}

"use client";

import type { Player, Thanks } from "~/contract";

import useSWR from "swr";

import { SplitFeedView } from "~/app/components/SplitFeedView";
import { Scoreboard } from "~/app/components/Scoreboard/Scoreboard";
import { Placeholder, PlaceholderLoading } from "~/app/components/Placeholder";

const _10_SECONDS = 10000;

const autoRefresh = {
  refreshInterval: _10_SECONDS,
};

const fetchJson = (url: string) => fetch(url).then((r) => r.json());

export default function ScoreboardPage(_: never) {
  const me = useSWR<Player>("/api/me", fetchJson);

  const players = useSWR<Player[]>("/api/score", fetchJson, autoRefresh);

  const feed = useSWR<Thanks[]>("/api/feed", fetchJson, autoRefresh);

  if (players.isLoading || feed.isLoading) {
    return <PlaceholderLoading />;
  }

  if (feed.data?.length) {
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
  if (players.data?.length) {
    return <Scoreboard players={players.data} useHighscore={false} />;
  }
  return <Placeholder />;
}

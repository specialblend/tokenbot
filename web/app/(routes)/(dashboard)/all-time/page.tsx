"use client";

import type { Player, Thanks } from "~/contract";

import useSWR from "swr";

import { SplitFeedView } from "~/app/components/SplitFeedView";
import { Scoreboard } from "~/app/components/Scoreboard/Scoreboard";
import {
  Placeholder,
  PlaceholderError,
  PlaceholderLoading,
} from "~/app/components/Placeholder";

const _10_SECONDS = 10000;

const autoRefresh = {
  refreshInterval: _10_SECONDS,
};

const fetchJson = (url: string) => fetch(url).then((r) => r.json());

export default function AllTimeScoreboardPage(_: never) {
  const me = useSWR<Player>("/api/me", fetchJson);
  const players = useSWR<Player[]>("/api/highscore", fetchJson, autoRefresh);
  const feed = useSWR<Thanks[]>("/api/feed", fetchJson, autoRefresh);

  if (players.isLoading || feed.isLoading) {
    return <PlaceholderLoading />;
  }

  if (players.error || feed.error) {
    return <PlaceholderError />;
  }

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

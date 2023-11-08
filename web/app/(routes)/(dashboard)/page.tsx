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

export default function ScoreboardPage(_: never) {
  const players = useSWR<Player[]>("/api/score", fetchJson, autoRefresh);
  const feed = useSWR<Thanks[]>("/api/feed", fetchJson, autoRefresh);

  if (players.isLoading || feed.isLoading) {
    return <PlaceholderLoading />;
  }

  if (players.error || feed.error) {
    return <PlaceholderError />;
  }

  if (feed.data?.length) {
    return (
      <SplitFeedView feed={feed.data}>
        <Scoreboard players={players.data ?? []} useHighscore={false} />
      </SplitFeedView>
    );
  }

  if (players.data?.length) {
    return <Scoreboard players={players.data} useHighscore={false} />;
  }

  return <Placeholder />;
}

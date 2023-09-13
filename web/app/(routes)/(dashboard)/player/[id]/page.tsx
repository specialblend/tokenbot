import type { ReactNode } from "react";

import { getFeedAbout, getPlayer } from "~/io/engine";
import { JetBrainsMono } from "~/app/fonts";
import { StatsTable } from "~/app/components/StatsTable";
import { SplitFeedView } from "~/app/components/SplitFeedView";
import { Inventory } from "~/app/components/Inventory";

export type PageProps = {
  params: { [key: string]: string };
  searchParams: { [key: string]: string | string[] | undefined };
};

function Score({
  score,
  children,
  className,
}: {
  score: number;
  children?: ReactNode;
  className?: string;
}) {
  return (
    <div className={className}>
      <div className="pr-8 pb-4">
        <div className={`text-8xl ${JetBrainsMono.className}`}>{score}</div>
        <div className="ink-muted text-lg">{children}</div>
      </div>
    </div>
  );
}

function Scores({ score, highscore }: { score: number; highscore: number }) {
  if (score === highscore) {
    return <Score score={score} />;
  }
  return (
    <div className="lg:flex">
      <Score score={score}>Current Score</Score>
      <Score score={highscore} className="text-amber-300">
        Lifetime Score
      </Score>
    </div>
  );
}

function Header({ children }: { children: ReactNode }) {
  return <div className="text-2xl ink-dimmed py-2">{children}</div>;
}

function Block({ children }: { children: ReactNode }) {
  return <div className="py-4 px-8 border-b border-primary">{children}</div>;
}

export default async function PlayerPage(
  { params: { id } }: PageProps,
  f = { getPlayer },
) {
  const player = await f.getPlayer(id);

  if (!player) return null;

  const { items, highscore, score } = player;
  const feed = await getFeedAbout(id, 25);

  return (
    <SplitFeedView feed={feed}>
      <div>
        <div className="py-4">
          <Block>
            <div className="text-4xl font-light">@{player.name}</div>
            <div className="py-4">
              <Inventory items={items} />
            </div>
          </Block>
          <Block>
            <Header>Score</Header>
            <Scores score={score.total} highscore={highscore} />
          </Block>
          <Block>
            <Header>Stats</Header>
            <StatsTable player={player} />
          </Block>
        </div>
      </div>
    </SplitFeedView>
  );
}

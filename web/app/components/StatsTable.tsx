import type { Player } from "~/contract";
import type { ReactNode } from "react";

import { JetBrainsMono } from "~/app/fonts";

function Stat({ children }: { children: ReactNode }) {
  return (
    <div className={`text-8xl font-light ${JetBrainsMono.className}`}>
      {children}
    </div>
  );
}

function StatPercent({ children }: { children: ReactNode }) {
  return (
    <div className={`text-8xl font-light ${JetBrainsMono.className}`}>
      {children}
      <span className="text-4xl">%</span>
    </div>
  );
}

export function StatBadgePercent({
  label,
  stat,
}: {
  label: string;
  stat: number;
}) {
  const style = stat > 0 ? "" : "ink-muted";
  return (
    <div className={`pr-16 pb-4 items-center ${style}`}>
      <StatPercent>{stat}</StatPercent>
      <div className="text-xl">{label}</div>
    </div>
  );
}

export function StatBadge({ label, stat }: { label: string; stat: number }) {
  const style = stat > 0 ? "" : "ink-muted";
  return (
    <div className={`pr-16 pb-4 items-center ${style}`}>
      <Stat>{stat}</Stat>
      <div className="text-xl">{label}</div>
    </div>
  );
}

export function StatsTable({ player }: { player: Player }) {
  return (
    <>
      <div className="lg:flex">
        <StatBadgePercent label="🍀 Luck" stat={player.luck} />
        <StatBadge label="🔥 Bonus Points" stat={player.score.bonus} />
      </div>
    </>
  );
}

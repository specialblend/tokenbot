import type { Stats } from "~/contract";
import type { ReactNode } from "react";

import { JetBrainsMono } from "~/app/fonts";

function Stat({ children }: { children: ReactNode }) {
  return (
    <div className={`text-8xl font-light ${JetBrainsMono.className}`}>
      {children}
      <span className="text-4xl">%</span>
    </div>
  );
}

export function StatBadge({ label, stat }: { label: string; stat: number }) {
  let style = stat > 0 ? "" : "ink-muted";
  return (
    <div className={`pr-16 pb-4 items-center ${style}`}>
      <Stat>{stat}</Stat>
      <div className="text-xl">{label}</div>
    </div>
  );
}

export function StatsTable({ stats }: { stats: Stats }) {
  let { bonus, luck, greed } = stats;
  return (
    <div className="lg:flex">
      <StatBadge label="🔥 Bonus" stat={bonus} />
      <StatBadge label="🍀 Luck" stat={luck} />
      <StatBadge label="🎃 Greed" stat={greed} />
    </div>
  );
}

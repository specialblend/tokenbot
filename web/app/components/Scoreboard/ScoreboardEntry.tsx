"use client";

import "./Scoreboard.css";
import type { Player } from "~/contract";

import { useRouter } from "next/navigation";
import Link from "next/link";

import { JetBrainsMono } from "~/app/fonts";
import { Inventory } from "~/app/components/Inventory";

export function ScoreboardEntry({
  rank,
  player,
  useHighscore,
  className = "",
}: {
  player: Player;
  className?: string;
  rank?: number;
  useHighscore?: boolean;
}) {
  const { score, highscore, items } = player;
  const router = useRouter();
  const score_ = useHighscore ? highscore : score.total;

  return (
    <tr
      className={`border-y border hover:bg-[#202020] hover:cursor-pointer ${className}`}
      onClick={() => {
        router.push(`/player/${player.id}`);
      }}
    >
      <td className="w-[1rem]">
        <span className="text-2xl ink-muted font-light">{rank || "-"}</span>
      </td>
      <td className="w-[180px] lg:w-1/3">
        <Link href={`/player/${player.id}`}>
          <span className="lg:text-2xl lg:font-light">@{player.name}</span>
        </Link>
      </td>
      <td className="w-[96px] lg:w-1/4">
        <span
          className={`text-3xl lg:text-4xl ${JetBrainsMono.className} ${
            (useHighscore && "text-amber-300") || ""
          }`}
        >
          {score_}
        </span>
      </td>
      <td className="max-w-xs hidden sm:table-cell">
        <Inventory items={items} />
      </td>
    </tr>
  );
}

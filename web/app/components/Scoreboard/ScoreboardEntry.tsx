"use client";

import "./Scoreboard.css";

import type { Player as TPlayer, User } from "~/contract";

import { useRouter } from "next/navigation";
import Link from "next/link";

import { fmtUserName } from "~/util/fmt";
import { JetBrainsMono } from "~/app/fonts";
import { Inventory } from "~/app/components/Inventory";

export function ScoreboardEntry({
  rank,
  user,
  player,
  useHighscore,
  className = "",
}: {
  user?: User;
  player: TPlayer;
  className?: string;
  rank?: number;
  useHighscore?: boolean;
}) {
  let { id, score, highscore, inventory } = player;
  let router = useRouter();
  let score_ = useHighscore ? highscore : score;
  let href = `/player/${id}`;

  return (
    <tr
      className={`border-y border hover:bg-[#202020] hover:cursor-pointer ${className}`}
      onClick={() => {
        router.push(href);
      }}
    >
      <td className="w-[1rem]">
        <span className="text-2xl ink-muted font-light">{rank || "-"}</span>
      </td>
      <td className="w-[180px] lg:w-1/3">
        <Link href={href}>
          <span className="lg:text-2xl lg:font-light">
            {fmtUserName(id, user)}
          </span>
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
      <td className="max-w-xs hidden lg:table-cell">
        <Inventory inventory={inventory} />
      </td>
    </tr>
  );
}

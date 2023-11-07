import type { Player } from "~/contract";

import { ScoreboardEntry } from "~/app/components/Scoreboard/ScoreboardEntry";

import "~/app/globals.css";
import "./Scoreboard.css";

export function Scoreboard({
  players,
  useHighscore,
}: {
  players: Player[];
  useHighscore?: boolean;
}) {
  return (
    <div className="scoreboard md:h-[calc(100vh-3rem)">
      <table>
        <thead className="ink-muted">
          <tr>
            <th className="max-w-[1rem]">#</th>
            <th>Name</th>
            <th>Score</th>
            <th className="hidden sm:table-cell">Tokens</th>
          </tr>
        </thead>
        <tbody>
          {players.map((player, key) => (
            <ScoreboardEntry
              key={key}
              rank={key + 1}
              player={player}
              useHighscore={useHighscore}
            />
          ))}
        </tbody>
      </table>
    </div>
  );
}

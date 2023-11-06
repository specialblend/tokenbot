import type { Player } from "~/contract";

import { ScoreboardEntry } from "~/app/components/Scoreboard/ScoreboardEntry";

import "~/app/globals.css";
import "./Scoreboard.css";

export function Scoreboard({
  players,
  me,
  useHighscore,
}: {
  players: Player[];
  me?: Player;
  useHighscore?: boolean;
}) {
  const playersIncludeMe = players.some((player) => player.id === me?.id);
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
          {me && !playersIncludeMe && (
            <>
              <tr>
                <td className="ink-muted">...</td>
              </tr>
              {me && <ScoreboardEntry player={me} className="text-amber-400" />}
            </>
          )}
        </tbody>
      </table>
    </div>
  );
}

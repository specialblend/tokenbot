import type { Player } from "~/contract";

import { getUser } from "~/io/engine";
import { ScoreboardEntry } from "~/app/components/Scoreboard/ScoreboardEntry";

import "~/app/globals.css";
import "./Scoreboard.css";

export async function Scoreboard({
  players,
  me,
  useHighscore,
}: {
  players: Player[];
  me?: Player;
  useHighscore?: boolean;
}) {
  let playersIncludeMe = players.some((player) => player.id === me?.id);
  return (
    <div className="scoreboard h-fill">
      <table>
        <thead className="ink-muted">
          <tr>
            <th className="max-w-[1rem]">#</th>
            <th>Name</th>
            <th>Score</th>
            <th className="hidden lg:table-cell">Tokens</th>
          </tr>
        </thead>
        <tbody>
          {players.map(async (player, key) => (
            <ScoreboardEntry
              key={key}
              rank={key + 1}
              player={player}
              user={await getUser(player.id)}
              useHighscore={useHighscore}
            />
          ))}
          {me && !playersIncludeMe && (
            <>
              <tr>
                <td className="ink-muted">...</td>
              </tr>
              {me && (
                <ScoreboardEntry
                  player={me}
                  user={await getUser(me.id)}
                  className="text-amber-400"
                />
              )}
            </>
          )}
        </tbody>
      </table>
    </div>
  );
}

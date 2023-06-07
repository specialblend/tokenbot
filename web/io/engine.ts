import type { Feed, Player, PlayerId, User } from "~/contract";

import * as ChildProcess from "child_process";

let callEngine = <T>(args: any[]): Promise<T> => {
  return new Promise<T>((resolve, reject) => {
    let bin = "./bin/tokenbot.exe";
    function handle(err: any, stdout: string, stderr: any) {
      if (err) return void reject(err);
      if (stderr) return void reject(stderr);
      return void resolve(JSON.parse(stdout) as T);
    }
    ChildProcess.execFile(bin, args, handle);
  });
};

export let getScoreboard = ({ useHighscore = false, count = 0 } = {}) => {
  if (useHighscore) {
    return callEngine<Player[]>(["highscoreboard", count]);
  }
  return callEngine<Player[]>(["scoreboard", count]);
};

export let getFeed = (count = 0) => callEngine<Feed>(["feed", count]);

export let getFeedAbout = (playerId: PlayerId, count = 0) =>
  callEngine<Feed>(["feed:about", playerId, count]);

export let getUser = (id: PlayerId) =>
  callEngine<User | null>(["user", id]).then((x) => x || undefined);

export let getPlayer = (id: PlayerId) =>
  callEngine<Player | undefined>(["player", id]);

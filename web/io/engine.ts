import type { Player, PlayerId, Thanks } from "~/contract";

import { red } from "~/io/red";

const isset = <T>(x: T | null | undefined): x is T => !!x;

const parser =
  <T>() =>
  (x: string) =>
    JSON.parse(x) as T;

export async function getPlayer(id: string) {
  const data = await red().get(`player:${id}`);
  if (data) return JSON.parse(data) as Player;
}

async function getScores(key: string, count = 16): Promise<Player[]> {
  const keys = await red().zrevrangebyscore(
    key,
    "+inf",
    "-inf",
    "LIMIT",
    0,
    count,
  );
  if (keys.length) {
    const data = await red().mget(keys.map((id) => `player:${id}`));
    return data.filter(isset).map(parser());
  }
  return [];
}

export async function getScoreboard(count = 16): Promise<Player[]> {
  return getScores("scores", count);
}

export async function getHighscoreBoard(count = 16): Promise<Player[]> {
  return getScores("highscores", count);
}

export async function getFeed(count = 32): Promise<Thanks[]> {
  const db = red();
  const keys = await db.lrange("thanks:@root", 0, count);
  if (keys.length) {
    const keys_ = keys.map((x) => `thanks:${x}`);
    const data = await db.mget(keys_);
    return data
      .filter((x): x is string => typeof x === "string")
      .map((x) => JSON.parse(x) as Thanks);
  }
  return [];
}

export async function getFeedAbout(
  playerId: PlayerId,
  count = 0,
): Promise<Thanks[]> {
  const db = red();
  const keys = await db.lrange(`thanks:@about:${playerId}`, 0, count);
  if (keys.length) {
    const keys_ = keys.map((x) => `thanks:${x}`);
    const data = await db.mget(keys_);
    return data
      .filter((x): x is string => typeof x === "string")
      .map((x) => JSON.parse(x) as Thanks);
  }
  return [];
}

console.debug({ pid: process.pid }, "io/engine.ts", __filename);

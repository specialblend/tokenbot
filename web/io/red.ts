import Redis from "ioredis";

const host = process.env.REDIS_HOST || "localhost";
const db = new Redis({ host, lazyConnect: true });

export const red = () => db;

console.debug({ pid: process.pid }, "io/red.ts", __filename);

import type { User } from "~/contract";
import type { JWT } from "next-auth/jwt";
import type { Session } from "next-auth";

export type AppSession = Session & {
  me: User & { id: string };
};

export function isAppSession(x?: JWT | Session | null): x is AppSession {
  return !!(
    x &&
    Reflect.has(x, "me") &&
    Reflect.has(Reflect.get(x, "me") as object, "id")
  );
}

console.debug({ pid: process.pid }, "auth/session.ts", __filename);

import type { Me } from "~/contract";
import type { JWT } from "next-auth/jwt";
import type { Session } from "next-auth";

export type AppSession = Session & {
  me: Me;
};

export function isAppSession(x?: JWT | Session | null): x is AppSession {
  if (x) {
    return "me" in x;
  }
  return false;
}

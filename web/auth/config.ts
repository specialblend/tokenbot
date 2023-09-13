import type { JWT } from "next-auth/jwt";
import type { NextAuthOptions } from "next-auth";

import { getUser } from "~/io/engine";
import { slackProvider } from "~/auth/slackProvider";

export const authOptions: NextAuthOptions = {
  callbacks: {
    async jwt({ token, account }): Promise<JWT> {
      if (account && token.sub) {
        const user = await getUser(token.sub);
        if (user) token.me = user;
      }
      return token;
    },
    session({ session, token }) {
      return {
        ...session,
        me: token.me,
      };
    },
  },
  providers: [slackProvider],
  pages: {
    signIn: "/signin",
  },
};

console.debug({ pid: process.pid }, "auth/config.ts", __filename);

import type { JWT } from "next-auth/jwt";
import type { NextAuthOptions } from "next-auth";

import { pickMe } from "~/util/fmt";
import { getUser } from "~/io/engine";
import { slackProvider } from "~/auth/slackProvider";

export let authOptions: NextAuthOptions = {
  callbacks: {
    async jwt({ token, account }): Promise<JWT> {
      if (account && token.sub) {
        let user = await getUser(token.sub);
        if (user) token.me = pickMe(user);
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

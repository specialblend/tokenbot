import { withAuth } from "next-auth/middleware";

import { isAppSession } from "~/auth/session";

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api (API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     */
    "/((?!api|signin|_next/static|_next/image|favicon.ico).*)",
  ],
};

export default withAuth({
  callbacks: {
    authorized: ({ token }) => {
      if (isAppSession(token) && process.env.SLACK_TEAM_ID) {
        return token.me.team_id === process.env.SLACK_TEAM_ID;
      }
      return false;
    },
  },
});

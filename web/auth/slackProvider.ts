import Slack from "next-auth/providers/slack";

export const slackProvider = Slack({
  clientId: process.env.SLACK_CLIENT_ID || "",
  clientSecret: process.env.SLACK_CLIENT_SECRET || "",
});

console.debug({ pid: process.pid }, "auth/slackProvider.ts", __filename);

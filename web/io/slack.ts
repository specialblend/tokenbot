import { WebClient } from "@slack/web-api";

export const slack = new WebClient(process.env.SLACK_BOT_TOKEN);

console.debug({ pid: process.pid }, "io/slack.ts", __filename);

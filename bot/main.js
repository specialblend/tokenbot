const childProcess = require("child_process");
const Bee = require("bee-queue");
const Slack = require("@slack/bolt");

const app = new Slack.App({
  token: process.env.SLACK_BOT_TOKEN,
  appToken: process.env.SLACK_APP_TOKEN,
  socketMode: true,
  logLevel: "error",
});

const host = process.env.REDIS_HOST || 'localhost';

const queue = new Bee("app_mentions", { redis: { host }});

queue.process(async job => {
  const payload = JSON.stringify(job.data);
  const input = Buffer.from(payload).toString('base64');
  try {
    const bin = "./tokenbot.exe";
    const args = [];
    const opts = { input };
    const out = childProcess.execFileSync(bin, args, opts).toString();
    console.log(out);
  } catch (err) {
    console.log(err.stdout.toString());
  }
});

app.event("app_mention", async ({ event }) => {
  await queue
    .createJob(event)
    .setId(event.client_msg_id)
    .save();
});

(async () => {
  await app.start();
  console.log("ready");
  process.on("SIGTERM", async () => {
    setTimeout(() => process.exit(1), 1000);
    await app.stop();
    process.exit();
  });
})();

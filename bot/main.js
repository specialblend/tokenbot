let childProcess = require("child_process");
let Bee = require("bee-queue");
let Slack = require("@slack/bolt");

let app = new Slack.App({
  token: process.env.SLACK_BOT_TOKEN,
  appToken: process.env.SLACK_APP_TOKEN,
  socketMode: true,
});

let host = process.env.REDIS_HOST || 'localhost';

let queue = new Bee("app_mentions", { redis: { host }});

queue.process(async job => {
  const payload = JSON.stringify(job.data);
  const input = Buffer.from(payload).toString('base64');
  try {
    const bin = "./tokenbot.exe";
    const args = ["msg"];
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

import type { Thanks } from "~/contract";
import type { PlayerDeposits } from "~/contract";

import * as timeago from "timeago.js";
import Link from "next/link";

import { timestamp } from "~/util/fmt";
import { fromShortcode } from "~/util/emoji";
import { DepositBadge } from "~/app/components/DepositBadge";

function fmtMentions(thanks: Thanks) {
  let text = `${thanks.msg.text}`;
  const ids = text.match(/<@(\w+)>/g)?.map((s) => s.slice(2, -1));
  ids?.forEach((id) => {
    const player = thanks.player_deposits.find(
      ([player_]) => player_.id === id,
    )?.[0];
    // TODO: this is a hack
    const repl = player?.name ?? "thanks";
    text = text.replace(`<@${id}>`, `@${repl}`);
  });
  return text;
}

function fmtEmojis(text_: string) {
  let text = `${text_}`;
  const shortcodes = text.match(/:([a-z0-9_]+):/g)?.map((s) => s.slice(1, -1));
  shortcodes?.forEach((shortcode: string) => {
    text = text.replace(`:${shortcode}:`, fromShortcode(shortcode) || "");
  });
  return text;
}

function fmtText(thanks: Thanks) {
  return fmtEmojis(fmtMentions(thanks));
}

function PlayerDepositsContainer({
  playerDeposits,
}: {
  playerDeposits: PlayerDeposits[];
}) {
  return (
    <>
      {playerDeposits.map(([player, deposits], key) => {
        return (
          <div key={key} className={"py-2"}>
            <div>
              <Link href={`/player/${player.id}`}>
                <span className="px-1 text-xl font-light ink-fire bg-carbon-400 rounded">
                  @{player.name}
                </span>
              </Link>
            </div>
            <>
              {deposits.map((deposit, key_) => {
                const {
                  item: [token, qty],
                  about,
                } = deposit;
                return (
                  <div key={key_} className="text-sm">
                    <DepositBadge token={token} qty={qty} about={about} />
                  </div>
                );
              })}
            </>
          </div>
        );
      })}
    </>
  );
}

function Txn({ thanks }: { thanks: Thanks }) {
  const time = timeago.format(timestamp(thanks));
  return (
    <div className="py-6 px-8 border-b border-primary">
      <div className="ink-dimmed py-2">
        <div className={`p-2 bg-carbon-500 rounded text-lg`}>
          {fmtText(thanks)}
        </div>
      </div>
      <div className="ink-muted text-sm">
        {time} from
        <Link href={`/player/${thanks.sender.id}`}>
          <span className="px-1 ink-dimmed">@{thanks.sender.name}</span>
        </Link>
      </div>
      <div className="py-2">
        <PlayerDepositsContainer playerDeposits={thanks.player_deposits} />
      </div>
    </div>
  );
}

export function Feed({ data }: { data: Thanks[] }) {
  return (
    <>
      {data.flatMap((thanks, key) => {
        return <Txn key={key} thanks={thanks} />;
      })}
    </>
  );
}

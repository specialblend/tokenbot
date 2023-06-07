import type { Deposit, Feed, Thanks, User } from "~/contract";

import * as timeago from "timeago.js";
import Link from "next/link";

import { fmtUserName, timestamp } from "~/util/fmt";
import { getUser } from "~/io/engine";
import { Txn } from "~/contract";
import { Quote } from "~/app/components/Quote";
import { DepositBadge } from "~/app/components/DepositBadge";

function Deposits({ deposits }: { deposits: Deposit[] }) {
  return (
    <>
      {deposits.map((deposit, key) => (
        <div key={key} className="text-sm">
          <DepositBadge {...deposit} />
        </div>
      ))}
    </>
  );
}

function DiffBadge(props: { diff?: number }) {
  let { diff } = props;
  if (typeof diff === "number") {
    if (diff > 0) return <span className="text-lime-500">+{diff}</span>;
    if (diff < 0) return <span className="text-red-500">{diff}</span>;
  }
  return null;
}

function TxnHeader({
  id,
  name,
  diff,
}: {
  id: string;
  name?: string;
  diff?: number;
}) {
  let href = `/player/${id}`;
  return (
    <>
      <Link href={href}>
        <span className="text-3xl font-light text-amber-400 hover:text-white">
          @{name || id}
        </span>
      </Link>
      <span className="px-2 text-lg">
        <DiffBadge diff={diff} />
      </span>
    </>
  );
}

function Txn(props: {
  txn: Txn;
  thanks: Thanks;
  diffs: Map<string, number>;
  user?: User;
  sender?: User;
}) {
  let { thanks, txn, diffs, user, sender } = props;
  let [id, deposits] = txn;
  let name = fmtUserName(id, user);
  let diff = diffs.get(id);
  let time = timeago.format(timestamp(thanks));
  return (
    <div className="py-6 px-8 border-b border-primary">
      <TxnHeader id={id} name={name} diff={diff} />
      <div className="ink-dimmed py-2">
        <Quote>{thanks.text}</Quote>
      </div>
      <div className="ink-muted text-sm">
        {time} from
        <Link href={`/player/${thanks.sender}`}>
          <span className="px-1 ink-dimmed">@{fmtUserName(id, sender)}</span>
        </Link>
      </div>
      <div className="py-2">
        <Deposits deposits={deposits} />
      </div>
    </div>
  );
}

export function Feed({
  data,
  allowZero,
  _getUser = getUser,
}: {
  data: Feed;
  allowZero?: boolean;
  _getUser?: typeof getUser;
}) {
  return (
    <>
      {data.flatMap((thanks, key) => {
        let diffs = new Map(thanks.diffs);

        return thanks.txns
          .filter(([id]) => allowZero || diffs.get(id))
          .map(async (txn) => {
            let [id] = txn;
            let [user, sender] = await Promise.all([
              _getUser(id),
              _getUser(thanks.sender),
            ]);
            let props = { thanks, txn, diffs, user, sender };
            return <Txn key={key} {...props} />;
          });
      })}
    </>
  );
}

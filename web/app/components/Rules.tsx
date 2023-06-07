import type { ReactNode } from "react";

import { Quote } from "~/app/components/Quote";
import { DepositBadge } from "~/app/components/DepositBadge";

export function Rules() {
  return (
    <div className="p-6">
      <Graph
        label="Send thanks in Slack"
        left={<Quote>@thanks @alice</Quote>}
        right={<DepositBadge token="🌮" qty={1} />}
      />

      <Graph
        label="Max recipients: 10"
        left={<Quote>@thanks @alice @bob</Quote>}
        right={<DepositBadge token="🌮" qty={1} />}
      />

      <Graph
        label="Super thanks (cooldown: 8 hrs)"
        left={<Quote>@thanks @alice 🌶️</Quote>}
        right={
          <>
            <DepositBadge token="🌮" qty={1} />
            <Plus />
            <DepositBadge token="🌶️" qty={1} />
          </>
        }
      />

      <Graph
        label="Hyper thanks (cooldown: 120 hrs)"
        left={<Quote>@thanks @alice 🔥</Quote>}
        right={
          <>
            <DepositBadge token="🌮" qty={1} />
            <Plus />
            <DepositBadge token="🔥" qty={1} />
          </>
        }
      />

      <Graph
        label="Monday bonus"
        left={<Quote>@thanks @alice</Quote>}
        right={
          <>
            <DepositBadge token="🌮" qty={1} />
            <Plus />
            <DepositBadge token="☕" qty={1} />
          </>
        }
      />

      <Graph
        label="Friday bonus"
        left={<Quote>@thanks @alice</Quote>}
        right={
          <>
            <DepositBadge token="🌮" qty={1} />
            <Plus />
            <DepositBadge token="🍻" qty={1} />
          </>
        }
      />

      <Graph
        label="[Free-for-all] Happy hour (4-5p)"
        left={<Quote>@thanks @alice</Quote>}
        right={
          <>
            <DepositBadge token="🌮" qty={1} />
            <Plus />
            <DepositBadge token="🍻" qty={1} />
          </>
        }
      />

      <Graph
        left={<DepositBadge token="🌮" qty={50} />}
        right={<DepositBadge token="🔥" qty={1} />}
        label="Token Exchange"
      />

      <Graph
        left={<DepositBadge token="🌶️" qty={10} />}
        right={<DepositBadge token="🔥" qty={1} />}
        label="Token Exchange"
      />

      <Graph
        left={<DepositBadge token="🍻" qty={25} />}
        right={<DepositBadge token="🍀" qty={1} />}
        label="Token Exchange"
      />

      <Graph
        left={<DepositBadge token="☕" qty={25} />}
        right={<DepositBadge token="🔥" qty={1} />}
        label="Token Exchange"
      />

      <Graph
        left={<DepositBadge token="🏷️" qty={50} />}
        right={<DepositBadge token="❓" qty={1} />}
        label="Token Exchange"
      />

      <Graph
        left={<DepositBadge token="⚠️" qty={3} />}
        right={<DepositBadge token="💀" qty={1} />}
        label="Token Exchange"
      />

      <Graph
        left={<DepositBadge token="🌶️" qty={1} />}
        right={<span className="ink-base text-base">+1% score</span>}
        label="Token Bonus"
      />

      <Graph
        left={<DepositBadge token="🔥" qty={1} />}
        right={<span className="ink-base text-base">+20% score</span>}
        label="Token Bonus"
      />

      <Graph
        left={<DepositBadge token="🍀" qty={1} />}
        right={<span className="ink-base text-base">+20% luck</span>}
        label="Token Bonus"
      />

      <Graph
        left={<DepositBadge token="🎃" qty={1} />}
        right={<span className="ink-base text-base">+20% greed</span>}
        label="Token Bonus"
      />

      <Graph
        left={<DepositBadge token="💀" qty={1} />}
        right={<span className="ink-base text-base">-20% score</span>}
        label="Token Penalty"
      />
    </div>
  );
}

function Graph(x: { left: ReactNode; right: ReactNode; label?: string }) {
  return (
    <Block>
      {x.left}
      <ArrowRight />
      {x.right}
      {x.label && (
        <div className="ink-muted pt-2">
          <span>{x.label}</span>
        </div>
      )}
    </Block>
  );
}

function Block(x: { children: ReactNode }) {
  return (
    <div className="py-6 first:pt-0 border-b border-primary">{x.children}</div>
  );
}

function Op({ children }: { children: ReactNode }) {
  return <span className="px-2 ink-muted text-lg">{children}</span>;
}

function ArrowRight() {
  return <Op>&#8594;</Op>;
}

function Plus() {
  return <Op>+</Op>;
}

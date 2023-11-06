import type { ReactNode } from "react";

import { Rules, TokenTable } from "~/app/components/Rules";

function Header({ children }: { children: ReactNode }) {
  return (
    <div className={"px-6 pt-6"}>
      <h1 className={"text-xl font-thin text-amber-500"}>{children}</h1>
    </div>
  );
}

export default function RulesPage() {
  return (
    <div>
      <Header>How To Play</Header>

      <Rules />
      <Header>Token Reference</Header>

      <TokenTable />
    </div>
  );
}

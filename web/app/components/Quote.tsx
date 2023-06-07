import type { ReactNode } from "react";

import { JetBrainsMono } from "~/app/fonts";

export function Quote({ children }: { children: ReactNode }) {
  return (
    <span
      className={`px-1 marker-dimmed rounded lg:text-base ${JetBrainsMono.className}`}
    >
      {children}
    </span>
  );
}

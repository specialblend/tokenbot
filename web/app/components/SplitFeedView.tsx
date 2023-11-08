import type { Thanks } from "~/contract";
import type { ReactNode } from "react";

import { Feed } from "~/app/components/Feed";

export function SplitFeedView({
  children,
  feed,
}: {
  children: ReactNode;
  feed: Thanks[];
}) {
  return (
    <div>
      <div className="lg:flex">
        <div className="w-full lg:h-[calc(100vh-3rem)] overflow-y-auto lg:w-2/3 overflow-x-hidden">
          {children}
        </div>
        <div className="w-full lg:h-[calc(100vh-3rem)] overflow-y-auto lg:w-1/3 border-l border-primary ">
          <Feed data={feed} />
        </div>
      </div>
    </div>
  );
}

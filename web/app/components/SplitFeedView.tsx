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
      <div className="sm:flex">
        <div className="w-full h-fill md:w-2/3 ">{children}</div>
        <div className="w-full h-fill md:w-1/3 border-l border-primary ">
          <Feed data={feed} />
        </div>
      </div>
    </div>
  );
}

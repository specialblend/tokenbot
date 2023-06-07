import type { Feed as TFeed } from "~/contract";
import type { ReactNode } from "react";

import { Feed } from "~/app/components/Feed";

export function SplitFeedView({
  children,
  feed,
  allowZero,
}: {
  children: ReactNode;
  feed: TFeed;
  allowZero?: boolean;
}) {
  return (
    <div>
      <div className="sm:flex">
        <div className="w-full h-fill md:w-2/3">{children}</div>
        <div className="w-full h-fill md:w-1/3 border-l border-primary">
          <Feed data={feed} allowZero={allowZero} />
        </div>
      </div>
    </div>
  );
}

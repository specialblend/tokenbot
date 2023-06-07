import type { AppSession } from "~/auth/session";

export function ProfilePic({ appSession }: { appSession: AppSession }) {
  return (
    <div className="flex items-center">
      <div className="rounded-full overflow-hidden border-2 border-carbon-200">
        <img
          style={{ maxWidth: "32px", maxHeight: "32px" }}
          className="w-8 h-8"
          src={appSession.user?.image || ""}
          alt={appSession.user?.name?.substring(0, 1) || "?"}
        />
      </div>
    </div>
  );
}

export function UserBadge({ appSession }: { appSession: AppSession }) {
  return (
    <div className="flex items-center">
      <div className="sm:hidden pr-4">
        <ProfilePic appSession={appSession} />
      </div>
      <div>
        <div className="text-lg">{appSession.me.real_name}</div>
        <div className="ink-muted">{appSession.user?.email}</div>
      </div>
    </div>
  );
}

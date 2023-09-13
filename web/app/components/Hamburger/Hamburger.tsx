import "./Hamburger.css";

import type { ReactNode } from "react";
import type { Session } from "next-auth";

import { signOut } from "next-auth/react";
import { useRouter } from "next/navigation";
import Link from "next/link";

import { isAppSession } from "~/auth/session";
import { UserBadge } from "~/app/components/UserBadge";

function Burger() {
  return (
    <div className="hamburger bg-carbon-500 pt-1">
      <span className="hamburger-line"></span>
      <span className="hamburger-line"></span>
      <span className="hamburger-line"></span>
    </div>
  );
}

function Close() {
  return (
    <div className="hamburger p-4 bg-carbon-400">
      <svg
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="3"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        <line x1="18" y1="6" x2="6" y2="18" />
        <line x1="6" y1="6" x2="18" y2="18" />
      </svg>
    </div>
  );
}

export function Item({
  href,
  onClick,
  children,
}: {
  href?: string;
  onClick?: () => void;
  children: ReactNode;
}) {
  const router = useRouter();
  return (
    <div
      className="p-4 hover:bg-carbon-500 border-b border-carbon-200"
      role="button"
      tabIndex={1}
      onClick={(event) => {
        event.stopPropagation();
        if (onClick) onClick();
        if (href) router.push(href);
      }}
    >
      {href ? <Link href={href}>{children}</Link> : children}
    </div>
  );
}

export function Menu({
  session,
  isOpen,
}: {
  session: Session | null;
  isOpen: boolean;
}) {
  if (isAppSession(session)) {
    return (
      <div
        className={`sm:fixed right-0 overflow-hidden transition-all duration-250 ease ${
          isOpen ? "max-h-40" : "max-h-0"
        }`}
      >
        <div className="bg-carbon-400 w-screen sm:w-72">
          <Item href={`/player/${session.me.id}`}>
            <UserBadge appSession={session} />
          </Item>
          <Item href="/" onClick={() => void signOut()}>
            <span className="pr-2">👋</span>
            Logout
          </Item>
        </div>
      </div>
    );
  }
  return null;
}

export function Hamburger({ isOpen }: { isOpen: boolean }) {
  if (isOpen) {
    return (
      <div className="h-full">
        <Close />
      </div>
    );
  }
  return <Burger />;
}

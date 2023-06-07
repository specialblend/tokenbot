"use client";

import type { ReactNode } from "react";
import type { Session } from "next-auth";

import { useState } from "react";
import { useSession } from "next-auth/react";
import { usePathname } from "next/navigation";
import Link from "next/link";

import { isAppSession } from "~/auth/session";
import { ProfilePic } from "~/app/components/UserBadge";
import { Spinner } from "~/app/components/Spinner";
import { Logo } from "~/app/components/Logo";
import { Hamburger, Menu } from "~/app/components/Hamburger/Hamburger";
import { useDismiss } from "~/app/(hooks)/useDismiss";
import "./Navbar.css";

function isActive(href: string) {
  let pathname = usePathname();
  if (href === "/") {
    return href === pathname;
  }
  return pathname && pathname.startsWith(href);
}

function NavBarItem({
  href,
  children,
  onClick,
}: {
  href: string;
  onClick?: () => void;
  children: ReactNode;
}) {
  let style = isActive(href) ? "navbar-tab-active" : "";
  return (
    <Link href={href} className="navbar-link">
      <div
        role="button"
        tabIndex={1}
        onClick={onClick}
        className={`navbar-tab ${style}`}
      >
        {children}
      </div>
    </Link>
  );
}

function HamburgerBtn({
  onClick,
  isOpen,
}: {
  onClick: () => void;
  isOpen: boolean;
}) {
  return (
    <button className="ml-0 sm:hidden" onClick={onClick}>
      <Hamburger isOpen={isOpen} />
    </button>
  );
}

function ProfileBtn({
  onClick,
  isOpen,
  session,
}: {
  onClick: () => void;
  isOpen: boolean;
  session: Session | null;
}) {
  return (
    <button
      className={`ml-0 px-4 hidden sm:inline-block ${
        isOpen ? "bg-carbon-400" : ""
      }`}
      onClick={onClick}
    >
      {isAppSession(session) ? (
        <ProfilePic appSession={session} />
      ) : (
        <Spinner />
      )}
    </button>
  );
}

export function Navbar() {
  let [isOpen, setIsOpen] = useState(false);
  let Toggle = () => setIsOpen(!isOpen);
  let { data: session } = useSession();

  useDismiss(() => setIsOpen(false));

  return (
    <div>
      <nav className="flex navbar" role="navigation">
        <div className="hidden sm:flex items-center justify-center px-4 bg-carbon-500 ">
          <Logo />
        </div>
        <NavBarItem href="/">️〽️ Latest</NavBarItem>
        <NavBarItem href="/all-time">💯 All-time</NavBarItem>
        <NavBarItem href="/rules">⁉️ Rules</NavBarItem>
        <div className="flex-grow"></div>
        <HamburgerBtn onClick={Toggle} isOpen={isOpen} />
        <ProfileBtn onClick={Toggle} isOpen={isOpen} session={session} />
      </nav>
      <Menu session={session} isOpen={isOpen} />
    </div>
  );
}

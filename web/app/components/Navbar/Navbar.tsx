"use client";

import type { ReactNode } from "react";

import { usePathname } from "next/navigation";
import Link from "next/link";

import { Logo } from "~/app/components/Logo";
import "./Navbar.css";

function isActive(href: string) {
  const pathname = usePathname();
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
  const style = isActive(href) ? "navbar-tab-active" : "";
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

export function Navbar() {
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
      </nav>
    </div>
  );
}

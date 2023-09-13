import "normalize.css";
import type { ReactNode } from "react";

import { SourceSansPro } from "~/app/fonts";
import { Providers } from "~/app/components/Providers";
import { Logo } from "~/app/components/Logo";

import "../../globals.css";

export const metadata = {
  title: "tokenbot",
  description: "tokenbot",
};

export default function Layout({ children }: { children: ReactNode }) {
  return (
    <html>
      <body className={SourceSansPro.className}>
        <Providers>
          <main className="flex h-screen w-screen items-center justify-center">
            <div className="text-center">
              <div className="text-3xl">
                <Logo />
              </div>
              <div className="p-8">{children}</div>
            </div>
          </main>
        </Providers>
      </body>
    </html>
  );
}

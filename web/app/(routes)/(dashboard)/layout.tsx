import "normalize.css";
import "../../globals.css";

import type { ReactNode } from "react";

import { SourceSansPro } from "~/app/fonts";
import { Providers } from "~/app/components/Providers";
import { Navbar } from "~/app/components/Navbar/Navbar";

export const metadata = {
  title: "tokenbot",
  description: "tokenbot",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html>
      <body className={SourceSansPro.className}>
        <Providers>
          <Navbar />
          <main>{children}</main>
        </Providers>
      </body>
    </html>
  );
}

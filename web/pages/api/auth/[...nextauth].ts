import NextAuth from "next-auth";

import { authOptions } from "~/auth/config";

export default NextAuth(authOptions);

console.debug({ pid: process.pid }, "[...nextauth].ts", __filename);

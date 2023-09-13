import type { Thanks } from "~/contract";

export function timestamp(thx: Thanks) {
  return new Date(parseFloat(thx.msg.ts) * 1000);
}

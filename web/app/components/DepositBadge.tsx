import { JetBrainsMono } from "~/app/fonts";

function style(token: string) {
  if (["🌮", "🏷️"].includes(token)) {
    return "ml-2 ink-muted";
  }
  if (["🌶️"].includes(token)) {
    return "ml-2 bg-red-900 rounded px-1";
  }
  if (["🔥"].includes(token)) {
    return "ml-2 bg-amber-800 rounded px-1";
  }
  return "ml-2 ink-dimmed";
}

export function DepositBadge({
  token,
  qty,
  about,
}: {
  token: string;
  qty: number;
  about?: string;
}) {
  let qty_ = qty >= 0 ? qty : `(${qty})`;
  return (
    <span className={JetBrainsMono.className}>
      <span className="text-xl">{token}</span>
      <span className="text-sm marker-dimmed">x{qty_}</span>
      {about && <span className={style(token)}>{about}</span>}
    </span>
  );
}

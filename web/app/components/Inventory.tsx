import type { Item } from "~/contract";

const ABOUT = {
  "🌮": "+1 pts",
  "🍻": "+1 pts",
  "☕️": "+1 pts",
  "🎃": "+1 pts",
  "🍉": "+13 pts",
  "🎁": "+0 pts",
  "🏷️": "+0 pts",
  "🍀": "+1 pts, +20% luck bonus",
  "🌶️": "+3 pts, +1% score bonus",
  "🔥": "+7 pts, +20% score bonus",
  "💀": "-5 pts, -10% score penalty",
};

function about(token: string) {
  const about_ = ABOUT[token as keyof typeof ABOUT];
  return `${token} ${about_ || ""}`;
}

export function ItemBadge({ item: [token, qty] }: { item: Item }) {
  return (
    <abbr title={about(token)}>
      <span className="text-2xl">{token}</span>
      <span className="px-1 text-sm">{qty}</span>
    </abbr>
  );
}

export function Inventory({ items }: { items: Item[] }) {
  return (
    <div className="flex-nowrap">
      {items.map((item, key) => (
        <ItemBadge key={key} item={item} />
      ))}
    </div>
  );
}

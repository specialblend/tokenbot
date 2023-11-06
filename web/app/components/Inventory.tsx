import type { Item } from "~/contract";

const ABOUT = {
  "🌮": "taco: +1 point",
  "🍻": "beer: +1 point",
  "☕️": "coffee: +1 point",
  "🎃": "pumpkin: +1 point",
  "🍀": "clover: +1 point, +20% luck bonus",
  "🌶️": "pepper: +3 points, +1% score bonus",
  "🔥": "fire: +7 points, +20% score bonus",
  "🍉": "watermelon: +13 points",
  "🎁": "mystery box: +0 points",
  "💀": "skull: -5 points, -10% score penalty",
  "🏷️": "receipt: +0 points",
};

export function ItemBadge({ item: [token, qty] }: { item: Item }) {
  return (
    <abbr title={ABOUT[token as keyof typeof ABOUT] || "token"}>
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

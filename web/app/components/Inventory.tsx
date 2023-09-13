import type { Item } from "~/contract";

export function ItemBadge({ item: [token, qty] }: { item: Item }) {
  return (
    <>
      <span className="text-2xl">{token}</span>
      <span className="px-1 text-sm">{qty}</span>
    </>
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

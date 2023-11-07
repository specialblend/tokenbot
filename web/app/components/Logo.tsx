import { JetBrainsMono } from "~/app/fonts";

export function Logo() {
  return (
    <div className={`font-light ink-muted ${JetBrainsMono.className}`}>
      🔥<span className="text-white">tokenbot</span>
    </div>
  );
}

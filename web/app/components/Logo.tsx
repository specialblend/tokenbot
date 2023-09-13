import { JetBrainsMono } from "~/app/fonts";

export function Logo() {
  return (
    <div className={`font-light ink-muted ${JetBrainsMono.className}`}>
      🔥<span className="text-white">tokenbot</span>
      {/*<span className="ink-muted">.dev</span>*/}
    </div>
  );
}

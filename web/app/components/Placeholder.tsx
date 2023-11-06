import Link from "next/link";

import { JetBrainsMono } from "~/app/fonts";
import { Spinner } from "~/app/components/Spinner";

export function Placeholder() {
  return (
    <>
      <div className="flex justify-center pt-36">
        <div className="text-center p-4">
          <div className={`ink-muted p-2 ${JetBrainsMono.className}`}>
            ⭕ waiting for players
          </div>
          <div className="ink-dimmed p-2">
            <p>
              Be first to send thanks to other players by mentioning them in
              Slack with <span className="marker-dimmed ink-base">@thanks</span>
            </p>
          </div>
          <div className="p-2 text-lg">
            <Link href="/rules">⁉️ See rules</Link>
          </div>
        </div>
      </div>
    </>
  );
}

export function PlaceholderError() {
  return (
    <>
      <div className="flex justify-center pt-36">
        <div className="text-center p-4">
          <div className={`p-2`}>⚠️ There was an issue loading the data.</div>
          <div className="ink-dimmed p-2">
            <p>
              Be first to send thanks to other players by mentioning them in
              Slack with <span className="marker-dimmed ink-base">@thanks</span>
            </p>
          </div>
          <div className="p-2 text-lg">
            <Link href="/rules">⁉️ See rules</Link>
          </div>
        </div>
      </div>
    </>
  );
}

export function PlaceholderLoading() {
  return (
    <>
      <div className="flex justify-center pt-36">
        <div className="text-center p-4">
          <div className={`ink-muted p-2 ${JetBrainsMono.className}`}>
            <Spinner />
          </div>
          <div className="ink-dimmed p-2">
            <p>
              Be first to send thanks to other players by mentioning them in
              Slack with <span className="marker-dimmed ink-base">@thanks</span>
            </p>
          </div>
          <div className="p-2 text-lg">
            <Link href="/rules">⁉️ See rules</Link>
          </div>
        </div>
      </div>
    </>
  );
}

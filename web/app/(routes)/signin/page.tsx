"use client";

import { signIn, useSession } from "next-auth/react";
import { useRouter, useSearchParams } from "next/navigation";

import { slackProvider } from "~/auth/slackProvider";
import { Spinner } from "~/app/components/Spinner";

export default function SignInPage() {
  void useSearchParams(); // disable static render

  let { status } = useSession();
  let router = useRouter();
  if (status === "unauthenticated") {
    return (
      <div className="h-32">
        <button
          className="text-xl px-6 py-3 ink-dimmed rounded border-carbon-200 bg-carbon-400 hover:text-white hover:bg-carbon-200 font-light"
          onClick={() =>
            void signIn(slackProvider.id, { redirect: true }).catch(
              console.error,
            )
          }
        >
          Sign-in with Slack
        </button>
      </div>
    );
  }

  router.push("/");

  return (
    <div className="h-32">
      <Spinner />
    </div>
  );
}

import { useEffect } from "react";

export function useKeyboardDismiss(handler: () => void) {
  let handleKey = (event: KeyboardEvent) => {
    if (event.key === "Escape") handler();
  };
  useEffect(() => {
    document.addEventListener("keydown", handleKey);
    return () => {
      document.removeEventListener("keydown", handleKey);
    };
  });
}

export function useMouseDismiss(handler: () => void) {
  useEffect(() => {
    document.addEventListener("mousedown", handler);
    return () => {
      document.removeEventListener("mousedown", handler);
    };
  });
}

export function useDismiss(handler: () => void) {
  useMouseDismiss(handler);
  useKeyboardDismiss(handler);
}

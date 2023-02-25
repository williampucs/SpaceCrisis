import type { UserSnapshot } from "@onflow/fcl";

export const useCurrentUser = () =>
  useState<PlatformIdentity | null>("currentUser", () => ref(null));

export const useNetworkCorrect = () =>
  useState<boolean>("currentFlowNetworkCorrect", () => ref(false));

export const useWalletAccount = () =>
  useState<UserSnapshot | null>("currentFlowWalletAccount", () => ref(null));

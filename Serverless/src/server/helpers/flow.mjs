import * as fcl from "@onflow/fcl";

export const APP_IDENTIFIER = "Project U v0.1";

export function switchToMainnet() {
  fcl
    .config()
    .put("fcl.limit", 9999)
    .put("flow.network", "mainnet")
    .put("accessNode.api", "https://rest-mainnet.onflow.org");
}

export function switchToTestnet() {
  fcl
    .config()
    .put("fcl.limit", 9999)
    .put("flow.network", "testnet")
    .put("accessNode.api", "https://rest-testnet.onflow.org");
}

export function switchToEmulator() {
  fcl
    .config()
    .put("fcl.limit", 9999)
    .put("flow.network", "emulator")
    .put("accessNode.api", "http://localhost:8888");
}

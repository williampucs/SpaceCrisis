import * as fcl from "@onflow/fcl";
import * as flow from "./flow.mjs";
import { default as Signer } from "./signer.mjs";
import { acquireKeyIndex } from "./redis";

export async function sendTransactionWithKeyPool(
  signer: Signer,
  code: string,
  args: fcl.ArgumentFunction
): Promise<string | null> {
  const keyIndex = await acquireKeyIndex(signer.address);
  const authz = signer.buildAuthorization({
    accountIndex: keyIndex,
  });
  console.log("Picking Index:", keyIndex);
  return signer.sendTransaction(code, args, authz);
}

export function initializeFlow() {
  const runtimeCfg = useRuntimeConfig();

  switch (runtimeCfg.public.network) {
    case "mainnet":
      flow.switchToMainnet();
      break;
    case "testnet":
      flow.switchToTestnet();
      break;
    case "emulator":
    default:
      flow.switchToEmulator();
      break;
  }
}

export function initializeSigner(): Signer {
  initializeFlow();
  const runtimeCfg = useRuntimeConfig();

  const signer = new Signer(
    runtimeCfg.flowAdminAddress,
    runtimeCfg.flowPrivateKey,
    0,
    runtimeCfg.public.localContracts
      .split(",")
      .reduce<{ [key: string]: string }>((prev, curr) => {
        prev[curr] = runtimeCfg.public.flowServiceAddress;
        return prev;
      }, {})
  );
  return signer;
}

export async function verifyAccountProof(
  opt: OptionAccountProof
): Promise<boolean> {
  const config = useRuntimeConfig();
  initializeFlow();

  return await fcl.AppUtils.verifyAccountProof(
    config.public.title,
    {
      address: opt.address,
      nonce: opt.proofNonce,
      signatures: opt.proofSigs.map((one) => ({
        f_type: "CompositeSignature",
        f_vsn: "1.0.0",
        keyId: one.keyId,
        addr: one.addr,
        signature: one.signature,
      })),
    },
    {
      // use blocto adddres to avoid self-custodian
      // https://docs.blocto.app/blocto-sdk/javascript-sdk/flow/account-proof
      fclCryptoContract:
        config.public.network === "mainnet"
          ? "0xdb6b70764af4ff68"
          : "0x5b250a8a85b44a67",
    }
  );
}

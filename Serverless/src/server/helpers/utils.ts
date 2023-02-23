import * as fcl from "@onflow/fcl";
import * as flow from "./flow.mjs";
import { default as Signer } from "./signer.mjs";

export async function pickOneSigner(): Promise<Signer> {
  const config = useRuntimeConfig();

  const signer = new Signer(config.flowAdminAddress, config.flowPrivateKey, 0, {
    Interfaces: config.public.flowServiceAddress,
    Helper: config.public.flowServiceAddress,
    QueryStructs: config.public.flowServiceAddress,
    UserProfile: config.public.flowServiceAddress,
    FLOATVerifiers: config.public.flowServiceAddress,
    Community: config.public.flowServiceAddress,
    BountyUnlockConditions: config.public.flowServiceAddress,
    CompetitionService: config.public.flowServiceAddress,
  });
  return signer;
}

export async function verifyAccountProof(
  opt: OptionAccountProof
): Promise<boolean> {
  const config = useRuntimeConfig();
  const isProduction = config.public.network === "mainnet";

  if (isProduction) {
    flow.switchToMainnet();
  } else {
    flow.switchToTestnet();
  }

  return await fcl.AppUtils.verifyAccountProof(
    flow.APP_IDENTIFIER,
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
      fclCryptoContract: isProduction
        ? "0xdb6b70764af4ff68"
        : "0x5b250a8a85b44a67",
    }
  );
}

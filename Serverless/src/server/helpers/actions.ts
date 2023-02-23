import Signer from "./signer.mjs";
import * as fcl from "@onflow/fcl";
import {
  executeOrLoadFromRedis,
  acquireKeyIndex,
  releaseKeyIndex,
} from "./redis";

/// ------------------------------ Transactions ------------------------------

async function sendTransactionWithKeyPool(
  signer: Signer,
  code: string,
  args: fcl.ArgumentFunction
): Promise<string | null> {
  const keyIndex = await acquireKeyIndex(signer.address);
  const authz = signer.buildAuthorization({
    accountIndex: keyIndex,
  });
  const txid = await signer.sendTransaction(code, args, authz);
  // Not to watch
  // if (txid) {
  //   signer.onceTransactionSealed(txid, (tx) => {
  //     return releaseKeyIndex(signer.address, keyIndex);
  //   });
  // }
  return txid;
}

export async function txCtrlerSetupReferralCode(
  signer: Signer,
  target: string
) {
  return sendTransactionWithKeyPool(
    signer,
    await useStorage().getItem(
      "assets/server/cadence/transactions/ctrler-setup-referral-code.cdc"
    ),
    (arg, t) => [arg(target, t.Address)]
  );
}

/// ------------------------------ Scripts ------------------------------

export async function scCheckBountyComplete(
  signer: Signer,
  acct: string,
  bountyId: string
): Promise<boolean> {
  const code = await useStorage().getItem(
    `assets/server/cadence/scripts/check-bounty-complete.cdc`
  );
  if (typeof code !== "string") {
    throw new Error("Unknown script.");
  }
  return await signer.executeScript(
    code,
    (arg, t) => [arg(acct, t.Address), arg(bountyId, t.UInt64)],
    false
  );
}

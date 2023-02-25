import env from "dotenv";
import fs from "fs";
import path from "path";
import * as flow from "../../src/server/helpers/flow.mjs";
import Signer from "../../src/server/helpers/signer.mjs";

env.config();

export function buildSigner(
  signerAddress = process.env.NUXT_PUBLIC_FLOW_SERVICE_ADDRESS,
  privateKey = process.env.NUXT_FLOW_SERVICE_PRIVATE_KEY ||
    process.env.NUXT_FLOW_PRIVATE_KEY
) {
  const serviceAddress = process.env.NUXT_PUBLIC_FLOW_SERVICE_ADDRESS;
  if (!signerAddress || !privateKey || !serviceAddress) {
    throw new Error("Missing env");
  }
  switch (process.env.NUXT_PUBLIC_NETWORK) {
    case "mainnet":
      flow.switchToMainnet();
      break;
    case "testnet":
      flow.switchToMainnet();
      break;
    case "emulator":
    default:
      flow.switchToEmulator();
      break;
  }

  const jsonStr = fs.readFileSync(
    path.join(process.cwd(), "flow.json"),
    "utf8"
  );
  const flowJson = JSON.parse(jsonStr);
  let addressMap = {};
  for (const key in flowJson.contracts) {
    let one = flowJson.contracts[key];
    if (typeof one === "string") {
      addressMap[key] = serviceAddress;
    }
  }

  const keyIndex = 0;
  const signer = new Signer(signerAddress, privateKey, keyIndex, addressMap);
  return signer;
}

/**
 * @param {Signer} signer
 * @param {String} txid
 */
export async function watchTransaction(signer, txid) {
  if (!txid) return;

  await new Promise((resolve, reject) => {
    signer.watchTransaction(
      txid,
      (txid, errMsg) => {
        if (errMsg) {
          console.log("TxError: ", errMsg);
        } else {
          console.log(`TxSealed: ${txid}`);
          resolve();
        }
      },
      (code) => {
        console.log(`TxUpdated: ${txid} - code(${code})`);
      },
      (errorMsg) => {
        console.log("UnknownError: ", errorMsg);
      }
    );
  });
}

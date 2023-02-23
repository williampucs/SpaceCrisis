import fs from "fs";
import path from "path";

import * as utils from "./helpers/utils.mjs";

async function main() {
  const signer = utils.buildSigner();

  const code = fs.readFileSync(
    path.join(
      process.cwd(),
      "cadence/dev-challenge/transactions/service-setup-ctrl.cdc"
    ),
    "utf8"
  );

  if (
    process.env.NUXT_FLOW_ADMIN_ADDRESS !==
    process.env.NUXT_PUBLIC_FLOW_SERVICE_ADDRESS
  ) {
    const txid = await signer.sendTransaction(
      code,
      (arg, t) => [],
      signer.buildAuthorization(),
      [
        signer.buildAuthorization({
          address: process.env.NUXT_FLOW_ADMIN_ADDRESS,
          accountIndex: 0,
          privateKey: process.env.NUXT_FLOW_PRIVATE_KEY,
        }),
      ]
    );

    await utils.watchTransaction(signer, txid);
  } else {
    console.log("service address is same as admin address");
  }
}
main();

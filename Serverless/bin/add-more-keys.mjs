import fs from "fs";
import path from "path";

import * as utils from "./helpers/utils.mjs";

async function main() {
  const signer = utils.buildSigner(
    process.env.NUXT_FLOW_ADMIN_ADDRESS,
    process.env.NUXT_FLOW_PRIVATE_KEY
  );

  const code = fs.readFileSync(
    path.join(process.cwd(), "cadence/transactions/utils/add-more-keys.cdc"),
    "utf8"
  );

  const txid = await signer.sendTransaction(code, (arg, t) => [
    arg("99", t.Int),
  ]);

  await utils.watchTransaction(signer, txid);
}
main();

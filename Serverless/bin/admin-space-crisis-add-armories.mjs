import fs from "fs";
import path from "path";

import * as utils from "./helpers/utils.mjs";

async function main() {
  const signer = utils.buildSigner(
    process.env.NUXT_FLOW_ADMIN_ADDRESS,
    process.env.NUXT_FLOW_PRIVATE_KEY
  );

  const code = fs.readFileSync(
    path.join(
      process.cwd(),
      "cadence/transactions/admin-space-crisis-add-armories.cdc"
    ),
    "utf8"
  );

  const txid = await signer.sendTransaction(code, (arg, t) => [
    /**
      keys: [String],
      useNFTs: [Bool],
      levelMaxs: [UFix64],
      levelRatios: [UFix64],
      extra: [String?],
     */
    arg(["weapon01"], t.Array(t.String)),
    arg([false], t.Array(t.Bool)),
    arg(["9.9"], t.Array(t.UFix64)),
    arg(["1.0"], t.Array(t.UFix64)),
    arg([null], t.Array(t.Optional(t.String))),
  ]);

  await utils.watchTransaction(signer, txid);
}
main();

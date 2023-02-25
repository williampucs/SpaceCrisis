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

  const weapons = [
    {
      key: "weapon01",
      useNFT: false,
      max: "9.9",
      ratio: "1.0",
      extra: null,
    },
    {
      key: "weapon02",
      useNFT: true,
      max: "9.9",
      ratio: "1.0",
      extra: "FLOAT",
    },
    {
      key: "weapon03",
      useNFT: true,
      max: "9.9",
      ratio: "0.25",
      extra: "Starly",
    },
    {
      key: "weapon04",
      useNFT: true,
      max: "9.9",
      ratio: "0.25",
      extra: "ThingFundMembershipBadge",
    },
  ];

  const reduced = weapons.reduce(
    (prev, curr) => {
      prev.keys.push(curr.key);
      prev.useNFTs.push(curr.useNFT);
      prev.levelMaxs.push(curr.max);
      prev.levelRatios.push(curr.ratio);
      prev.extras.push(curr.extra);
      return prev;
    },
    {
      keys: [],
      useNFTs: [],
      levelMaxs: [],
      levelRatios: [],
      extras: [],
    }
  );

  const txid = await signer.sendTransaction(code, (arg, t) => [
    /**
     */
    arg(reduced.keys, t.Array(t.String)),
    arg(reduced.useNFTs, t.Array(t.Bool)),
    arg(reduced.levelMaxs, t.Array(t.UFix64)),
    arg(reduced.levelRatios, t.Array(t.UFix64)),
    arg(reduced.extras, t.Array(t.Optional(t.String))),
  ]);

  await utils.watchTransaction(signer, txid);
}
main();

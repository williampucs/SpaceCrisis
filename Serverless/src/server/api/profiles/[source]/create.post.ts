import { z, useValidatedParams, useValidatedBody } from "h3-zod";
import { utils } from "../../../helpers";

export default defineEventHandler<ResponsePostBasics>(async (event) => {
  const params = await useValidatedParams(
    event,
    z.object({
      source: z.string(),
    })
  );
  const body = await useValidatedBody(
    event,
    z.object({
      platform: z.string(),
      uid: z.string(),
    })
  );

  // initialize
  const signer = utils.initializeSigner();

  // invoke scripts
  const code = await useStorage().getItem(
    `assets/server/cadence/transactions/${params.source}/profile-create.cdc`
  );
  if (typeof code !== "string") {
    throw new Error("Invalid source or failed to load script");
  }
  const txid = await utils.sendTransactionWithKeyPool(
    signer,
    code,
    (arg, t) => [arg(body.platform, t.String), arg(body.uid, t.String)]
  );

  return {
    ok: txid !== null,
    txid,
  };
});

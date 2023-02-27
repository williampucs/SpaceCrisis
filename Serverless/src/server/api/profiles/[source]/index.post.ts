import { z, useValidatedParams, useValidatedBody } from "h3-zod";
import { utils } from "../../../helpers";

export default defineEventHandler<ResponsePostBasics>(async (event) => {
  const params = await useValidatedParams(
    event,
    z.object({
      source: z.string(),
    })
  );

  let body: PlatformIdentity;
  const b = await readBody(event);
  if (typeof b === "object") {
    body = await useValidatedBody(
      event,
      z.object({
        platform: z.string(),
        uid: z.string(),
      })
    );
  } else if (typeof b === "string") {
    const url = new URL("http://localhost/?" + b);
    const platform = url.searchParams.get("platform");
    const uid = url.searchParams.get("uid");
    if (platform && uid) {
      body = { platform, uid };
    } else {
      throw createError({
        statusCode: 400,
        statusMessage: `Invalid paramters: ${JSON.stringify(b)}`,
      });
    }
  }

  // initialize
  const signer = utils.initializeSigner();

  // invoke scripts
  const code = await useStorage().getItem(
    `assets/server/cadence/transactions/${params.source}/profile-create.cdc`
  );
  if (typeof code !== "string") {
    throw createError({
      statusCode: 400,
      statusMessage: "Invalid source or failed to load script",
    });
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

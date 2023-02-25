import { z, useValidatedParams, useValidatedBody } from "h3-zod";
import { utils } from "../../../../helpers";

export default defineEventHandler<ResponsePostBasics>(async (event) => {
  const params = await useValidatedParams(
    event,
    z.object({
      source: z.string(),
      userId: z.string(),
    })
  );
  const body = await useValidatedBody(
    event,
    z.object({
      method: z.string(),
      params: z.array(z.string()),
    })
  );

  // initialize
  const signer = utils.initializeSigner();

  const [platform, uid] = params.userId.split("-");
  if (typeof platform !== "string" || typeof uid !== "string") {
    throw createError({
      statusCode: 400,
      statusMessage: "Failed to parse userId",
    });
  }
  // invoke scripts
  const code = await useStorage().getItem(
    `assets/server/cadence/transactions/${params.source}/profile-${body.method}.cdc`
  );
  if (typeof code !== "string") {
    throw createError({
      statusCode: 400,
      statusMessage: "Invalid source or failed to load script",
    });
  }
  const schema = await useStorage().getItem(
    `assets/server/cadence/schemas/${params.source}/methods.json`
  );

  const paramTypes: string[] = schema?.profile?.[body.method];
  if (!Array.isArray(paramTypes)) {
    throw createError({
      statusCode: 400,
      statusMessage: "Invalid schema",
    });
  }

  const txid = await utils.sendTransactionWithKeyPool(signer, code, (arg, t) =>
    [arg(platform, t.String), arg(uid, t.String)].concat(
      body.params.map((value, i) => {
        const typeKey = paramTypes[i];
        switch (typeKey) {
          case "UFix64":
            return arg(parseFloat(value).toFixed(2), t.UFix64);
          case "Fix64":
            return arg(parseFloat(value).toFixed(2), t.Fix64);
          default:
            // @ts-ignore
            return arg(value, t[typeKey]);
        }
      })
    )
  );

  return {
    ok: txid !== null,
    txid,
  };
});

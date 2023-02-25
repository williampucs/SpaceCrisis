import { z, useValidatedParams } from "h3-zod";
import { utils } from "../../helpers";

export default defineEventHandler<ResponseServiceFetch>(async (event) => {
  const params = await useValidatedParams(
    event,
    z.object({
      source: z.string(),
    })
  );

  // initialize
  const signer = utils.initializeSigner();

  // invoke scripts
  const code = await useStorage().getItem(
    `assets/server/cadence/scripts/${params.source}/service-info-fetch.cdc`
  );
  if (typeof code !== "string") {
    throw new Error("Invalid source or failed to load script");
  }
  const info = await signer.executeScript(code, (arg, t) => [], null);
  if (!info || typeof info !== "object") {
    throw new Error("Failed to load service info");
  }

  return Object.assign(info, {
    availableArmories: info?.availableArmories?.map((one: any) =>
      parseArmory(one)
    ),
  });
});

function parseArmory(info: any): ArmoryDefination {
  return {
    key: info.key,
    levelMax: parseFloat(info.levelMax),
    levelRatio: parseFloat(info.levelRatio),
    bindingCollectionIdentifier: info.bindingCollectionIdentifier || undefined,
  };
}

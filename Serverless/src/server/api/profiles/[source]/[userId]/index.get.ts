import { z, useValidatedParams } from "h3-zod";
import { utils } from "../../../../helpers";

export default defineEventHandler<ResponseProfileFetch>(async (event) => {
  const params = await useValidatedParams(
    event,
    z.object({
      source: z.string(),
      userId: z.string(),
    })
  );

  // initialize
  const signer = utils.initializeSigner();

  const [platform, uid] = params.userId.split("-");
  if (typeof platform !== "string" || typeof uid !== "string") {
    throw new Error("Failed to parse userId");
  }
  // invoke scripts
  const code = await useStorage().getItem(
    `assets/server/cadence/scripts/${params.source}/profile-fetch.cdc`
  );
  if (typeof code !== "string") {
    throw new Error("Invalid source or failed to load script");
  }
  const info = await signer.executeScript(
    code,
    (arg, t) => [arg(platform, t.String), arg(uid, t.String)],
    null
  );
  if (!info || typeof info !== "object") {
    throw new Error("Failed to load profile info");
  }

  const equipments: { [key: string]: EquipmentStatus } = {};
  const parseEquipment = (eq: any): EquipmentStatus =>
    Object.assign(eq, { level: parseFloat(eq.level) });
  for (const key in info.equipments) {
    equipments[key] = parseEquipment(info.equipments[key]);
  }
  return Object.assign(info, { equipments });
});

import { z, useValidatedParams } from "h3-zod";
import * as fcl from "@onflow/fcl";
import { utils } from "../../helpers";

export default defineEventHandler<fcl.TransactionReceipt>(async (event) => {
  const params = await useValidatedParams(
    event,
    z.object({
      txid: z.string(),
    })
  );

  // initialize
  utils.initializeFlow();

  return await fcl
    .send([fcl.getTransactionStatus(params.txid)])
    .then(fcl.decode);
});

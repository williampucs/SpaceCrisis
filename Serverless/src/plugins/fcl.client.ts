import * as fcl from "@onflow/fcl";
import { send as grpcSend } from "@onflow/transport-grpc";
import cadence from "../assets/cadence";

export default defineNuxtPlugin((nuxtApp) => {
  const config = useRuntimeConfig();

  // initialize fcl
  fcl
    .config()
    .put("flow.network", config.public.network)
    .put("accessNode.api", config.public.accessApi)
    .put("discovery.wallet", config.public.walletDiscovery)
    .put("sdk.transport", grpcSend)
    .put("app.detail.title", config.public.title)
    .put(
      "app.detail.icon",
      window.location.origin + config.app.baseURL + "apple-touch-icon.png"
    )
    .put("service.OpenID.scopes", "email email_verified name zoneinfo")
    .put("fcl.limit", 9999)
    .put("fcl.accountProof.resolver", async () => {
      const data = await $fetch("/api/app-resolver");
      console.log("AccountProof Resolver:", data);
      return data;
    });

  // Address mapping
  const addressMapping = config.public.localContracts
    .split(",")
    .reduce<{ [key: string]: string }>((prev, curr) => {
      prev[curr] = config.public.flowServiceAddress;
      return prev;
    }, {});

  // ------ Build transactions ------

  const sendTransaction = async (
    code: string,
    args: fcl.ArgumentFunction
  ): Promise<string> => {
    let transactionId: string;

    try {
      transactionId = await fcl.mutate({
        cadence: replaceImportAddresses(code, addressMapping),
        args: args,
      });
      console.log("Tx Sent:", transactionId);
      return transactionId;
    } catch (e: any) {
      console.error(e);
      throw new Error(e.message);
    }
  };

  /**
   * @param transactionId
   * @param onSealed
   * @param onStatusUpdated
   * @param onErrorOccured
   */
  const watchTransaction = (
    transactionId: string,
    onSealed: (txId: string, errorMsg?: string) => void | undefined,
    onStatusUpdated: (code: fcl.TransactionStatus) => void | undefined,
    onErrorOccured: (errorMsg: string) => void | undefined
  ) => {
    fcl.tx(transactionId).subscribe((res) => {
      if (onStatusUpdated) {
        onStatusUpdated(res.status);
      }

      if (res.status === 4) {
        if (res.statusCode !== 0 && onErrorOccured) {
          onErrorOccured(res.errorMessage);
        }
        // on sealed callback
        if (typeof onSealed === "function") {
          onSealed(
            transactionId,
            res.statusCode === 0 ? undefined : res.errorMessage
          );
        }
      }
    });
  };

  /**
   * @param code
   * @param args
   * @param defaultValue
   */
  const executeScript = async (
    code: string,
    args: fcl.ArgumentFunction,
    defaultValue: any
  ): Promise<any> => {
    const cadence = replaceImportAddresses(code, addressMapping);
    try {
      const queryResult = await fcl.query({
        cadence,
        args,
      });
      return queryResult ?? defaultValue;
    } catch (e) {
      console.error(`[CODE]: ${cadence}`, args, e);
      return defaultValue;
    }
  };

  async function fetchAccountProof(): Promise<fcl.AccountProofData> {
    const user = await fcl.currentUser.snapshot();
    if (!user) {
      throw new Error("user not found");
    }
    const accountProof = user.services?.find(
      (one) => one.type === "account-proof"
    );
    if (!accountProof) {
      console.log("accountProof not found");
      throw new Error("accountProof not found");
    }
    return {
      address: user.addr!,
      nonce: accountProof.data.nonce,
      signatures: accountProof.data.signatures,
    };
  }

  return {
    provide: {
      fcl,
      watchTransaction,
      scripts: {
        async getProfileStatus(platform: string, uid: string) {
          return executeScript(
            cadence.scripts.getProfileStatus,
            (arg, t) => [arg(platform, t.String), arg(uid, t.String)],
            false
          );
        },
      },
      transactions: {
        async claimProfile(platform: string, uid: string) {
          const proof = await fetchAccountProof();
          const message = fcl.WalletUtils.encodeAccountProof(
            {
              address: proof.address,
              nonce: proof.nonce,
              appIdentifier: config.public.title,
            },
            false
          );
          const txid = await sendTransaction(
            cadence.transactions.claimProfile,
            (arg, t) => [
              arg(platform, t.String),
              arg(uid, t.String),
              arg(message, t.String),
              arg(
                proof.signatures.map((one) => one.keyId.toFixed(0)),
                t.Array(t.Int)
              ),
              arg(
                proof.signatures.map((one) => one.signature),
                t.Array(t.String)
              ),
            ]
          );
          return txid;
        },
      },
    },
  };
});

/**
 * Returns Cadence template code with replaced import addresses
 *
 * @param code - Cadence template code.
 * @param addressMap - name/address map or function to use as lookup table for addresses in import statements.
 * @param byName - lag to indicate whether we shall use names of the contracts.
 */
function replaceImportAddresses(
  code: string,
  addressMap: ((key: string) => string) | { [key: string]: string },
  byName = true
): string {
  const REGEXP_IMPORT = /(\s*import\s*)([\w\d]+)(\s+from\s*)([\w\d"-.\\/]+)/g;

  return code.replace(
    REGEXP_IMPORT,
    (match, imp: string, contract: string, _, address: string) => {
      const key = byName ? contract : address;
      const newAddress =
        addressMap instanceof Function ? addressMap(key) : addressMap[key];

      // If the address is not inside addressMap we shall not alter import statement
      const validAddress = newAddress || address;
      return `${imp}${contract} from ${validAddress}`;
    }
  );
}

interface OptionAccountProof {
  address: string;
  proofNonce: string;
  proofSigs: {
    keyId: number;
    addr: string;
    signature: string;
  }[];
}

interface ResponseBasics {
  ok: boolean;
  error?: {
    code: string;
    message: string;
  };
}

interface ResponseVerifyMission extends ResponseBasics {
  isAccountValid?: boolean;
  transactionId?: string | null;
}

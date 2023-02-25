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
  error?: {
    code: number | string;
    message: string;
  };
}

// models

interface PlatformIdentity {
  platform: string;
  uid: string;
}

interface Display {
  name: string;
  description: string;
  thumbnail?: string;
}

interface PlatformInfo {
  identity: PlatformIdentity;
  display?: Display;
}

interface EquipmentStatus {
  key: string;
  enabled: boolean;
  level: number;
}

// get request

interface ArmoryDefination {
  key: string;
  levelMax: number;
  levelRatio: number;
  bindingCollectionIdentifier?: string;
}

interface ResponseServiceFetch extends ResponseBasics {
  name: string;
  availableArmories: ArmoryDefination[];
  availableAircrafts: string[];
}

interface ResponseProfileFetch extends ResponseBasics {
  userId: string;
  isSelfAttached: boolean;
  ownerAddress?: string;
  info: PlatformInfo;
  unlockedAircrafts: string[];
  currentAircraft?: string;
  equipments: { [key: string]: EquipmentStatus };
}

// post request

interface ResponsePostBasics extends ResponseBasics {
  ok: boolean;
  txid?: string | null;
}

interface ResponseWithAccountProof extends ResponsePostBasics {
  isAccountValid: boolean;
}

interface ResponseInvokeMethod extends ResponsePostBasics {
  doesMethodExist: boolean;
}

interface ReqOptionsInvokeMethod {
  method: string;
  params: string[];
}

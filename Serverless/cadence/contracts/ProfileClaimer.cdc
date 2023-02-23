import FCLCrypto from "./deps/FCLCrypto.cdc"
import Helper from "./Helper.cdc"
import Interfaces from "./Interfaces.cdc"
import PlayerKit from "./PlayerKit.cdc"
import GameServices from "./GameServices.cdc"

pub contract ProfileClaimer {

  pub fun claimProfileFromHQ(
    source: String,
    identifier: Helper.PlatformIdentity,
    profilesWritableCap: Capability<&PlayerKit.Profiles{PlayerKit.ProfilesPrivate}>,
    messageToCheck: String,
    keyIndices: [Int],
    signatures: [String]
  ) {
    let hq = GameServices.borrowServiceHQ()
    assert(hq.isGuest(source, identifier: identifier), message: "The profile is not a guest")

    let profilesPubRef = PlayerKit.borrowProfilesPublic(profilesWritableCap.address)
      ?? panic("PlayerKit failed to load profile public")
    assert(profilesPubRef.borrowProfile(source) == nil, message: "The player already has a profile of the source: ".concat(source))

    let profilesPrivRef = profilesWritableCap.borrow() ?? panic("Invalid Capability")

    let isValidClaimer = FCLCrypto.verifyAccountProofSignatures(
      address: profilesWritableCap.address,
      message: messageToCheck,
      keyIndices: keyIndices,
      signatures: signatures
    )
    assert(isValidClaimer, message: "Invalid claimer: ".concat(profilesWritableCap.address.toString()))

    let claimedProfile <- hq.claimProfile(source, identifier: identifier)
    profilesPrivRef.attachProfile(profile: <- claimedProfile)
  }
}

import Helper from "../../../../cadence/contracts/Helper.cdc"
// import Interfaces from "../../../../cadence/contracts/Interfaces.cdc"
import PlayerKit from "../../../../cadence/contracts/PlayerKit.cdc"
// import GameServices from "../../../../cadence/contracts/GameServices.cdc"
import ProfileClaimer from "../../../../cadence/contracts/ProfileClaimer.cdc"
// import SpaceCrisisDefinition from "../../../../cadence/contracts/space-crisis/SpaceCrisisDefinition.cdc"
// import SpaceCrisisGameService from "../../../../cadence/contracts/space-crisis/SpaceCrisisGameService.cdc"
import SpaceCrisisPlayerProfile from "../../../../cadence/contracts/space-crisis/SpaceCrisisPlayerProfile.cdc"

transaction(
  platform: String,
  uid: String,
  messageToCheck: String,
  keyIndices: [Int],
  signatures: [String]
) {
    let privateCap: Capability<&PlayerKit.Profiles{PlayerKit.ProfilesPrivate}>

    prepare(acct: AuthAccount) {
      if acct.borrow<&PlayerKit.Profiles>(from: PlayerKit.PlayerKitStoragePath) == nil {
        acct.save(<- PlayerKit.createProfiles(), to: PlayerKit.PlayerKitStoragePath)
        acct.link<&PlayerKit.Profiles{PlayerKit.ProfliesPublic}>(PlayerKit.PlayerKitPublicPath, target: PlayerKit.PlayerKitStoragePath)
        acct.link<&PlayerKit.Profiles{PlayerKit.ProfilesPrivate}>(PlayerKit.PlayerKitPrivatePath, target: PlayerKit.PlayerKitStoragePath)
      }
      self.privateCap = acct.getCapability<&PlayerKit.Profiles{PlayerKit.ProfilesPrivate}>(PlayerKit.PlayerKitPrivatePath)
    }

    execute {
      ProfileClaimer.claimProfileFromHQ(
        source: SpaceCrisisPlayerProfile.sourceName,
        identifier: Helper.PlatformIdentity(platform, uid),
        profilesWritableCap: self.privateCap,
        messageToCheck: messageToCheck,
        keyIndices: keyIndices,
        signatures: signatures
      )
    }
}

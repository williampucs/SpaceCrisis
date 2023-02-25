import Helper from "../../../../cadence/contracts/Helper.cdc"
// import Interfaces from "../../../../cadence/contracts/Interfaces.cdc"
// import PlayerKit from "../../../../cadence/contracts/PlayerKit.cdc"
// import GameServices from "../../../../cadence/contracts/GameServices.cdc"
// import ProfileClaimer from "../../../../cadence/contracts/ProfileClaimer.cdc"
// import SpaceCrisisDefination from "../../../../cadence/contracts/space-crisis/SpaceCrisisDefination.cdc"
// import SpaceCrisisGameService from "../../../../cadence/contracts/space-crisis/SpaceCrisisGameService.cdc"
import SpaceCrisisPlayerProfile from "../../../../cadence/contracts/space-crisis/SpaceCrisisPlayerProfile.cdc"

pub fun main(
  platform: String,
  uid: String,
): Bool {
  let identifier = Helper.PlatformIdentity(platform, uid)
  if let profile = SpaceCrisisPlayerProfile.borrowProfilePublic(identifier) {
    return profile.isAttached
  }
  return false
}

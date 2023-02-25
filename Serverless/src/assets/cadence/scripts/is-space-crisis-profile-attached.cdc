import Helper from "../../../../cadence/contracts/Helper.cdc"
// import Interfaces from "../../../../cadence/contracts/Interfaces.cdc"
// import PlayerKit from "../../../../cadence/contracts/PlayerKit.cdc"
// import GameServices from "../../../../cadence/contracts/GameServices.cdc"
// import ProfileClaimer from "../../../../cadence/contracts/ProfileClaimer.cdc"
// import SpaceCrisisDefinition from "../../../../cadence/contracts/space-crisis/SpaceCrisisDefinition.cdc"
// import SpaceCrisisGameService from "../../../../cadence/contracts/space-crisis/SpaceCrisisGameService.cdc"
import SpaceCrisisPlayerProfile from "../../../../cadence/contracts/space-crisis/SpaceCrisisPlayerProfile.cdc"

pub fun main(
  platform: String,
  uid: String,
): Info {
  let identifier = Helper.PlatformIdentity(platform, uid)
  if let profile = SpaceCrisisPlayerProfile.borrowProfilePublic(identifier) {
    return Info(exists: true, attached: profile.isAttached)
  }
  return Info(exists: false, attached: false)
}

pub struct Info {
  pub let exists: Bool
  pub let attached: Bool

  init(
    exists: Bool,
    attached: Bool,
  ) {
    self.exists = exists
    self.attached = attached
  }
}

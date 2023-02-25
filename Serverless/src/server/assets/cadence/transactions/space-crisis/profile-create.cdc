// import Helper from "../../../../../../cadence/contracts/Helper.cdc"
// import Interfaces from "../../../../../../cadence/contracts/Interfaces.cdc"
// import PlayerKit from "../../../../../../cadence/contracts/PlayerKit.cdc"
import GameServices from "../../../../../../cadence/contracts/GameServices.cdc"
// import ProfileClaimer from "../../../../../../cadence/contracts/ProfileClaimer.cdc"
// import SpaceCrisisDefinition from "../../../../../../cadence/contracts/space-crisis/SpaceCrisisDefinition.cdc"
import SpaceCrisisGameService from "../../../../../../cadence/contracts/space-crisis/SpaceCrisisGameService.cdc"
// import SpaceCrisisPlayerProfile from "../../../../../../cadence/contracts/space-crisis/SpaceCrisisPlayerProfile.cdc"

transaction(
  platform: String,
  uid: String,
) {
    let ctrler: &GameServices.ServicesHQController

    prepare(acct: AuthAccount) {
      self.ctrler = acct.borrow<&GameServices.ServicesHQController>(from: GameServices.GameServicesControlerStoragePath)
                ?? panic("Not the service account.")
    }

    execute {
      self.ctrler.createProfile(SpaceCrisisGameService.sourceName, platform: platform, uid: uid)
    }
}

import Helper from "../../../../../../cadence/contracts/Helper.cdc"
// import Interfaces from "../../../../../../cadence/contracts/Interfaces.cdc"
// import PlayerKit from "../../../../../../cadence/contracts/PlayerKit.cdc"
import GameServices from "../../../../../../cadence/contracts/GameServices.cdc"
// import ProfileClaimer from "../../../../../../cadence/contracts/ProfileClaimer.cdc"
// import SpaceCrisisDefination from "../../../../../../cadence/contracts/space-crisis/SpaceCrisisDefination.cdc"
import SpaceCrisisGameService from "../../../../../../cadence/contracts/space-crisis/SpaceCrisisGameService.cdc"
// import SpaceCrisisPlayerProfile from "../../../../../../cadence/contracts/space-crisis/SpaceCrisisPlayerProfile.cdc"

transaction(
  platform: String,
  uid: String,
  prop: String,
  value: UFix64,
) {
    let ctrler: &GameServices.ServicesHQController
    let service: &SpaceCrisisGameService.Service

    prepare(acct: AuthAccount) {
      self.ctrler = acct.borrow<&GameServices.ServicesHQController>(from: GameServices.GameServicesControlerStoragePath)
                ?? panic("Not the service account.")
      let gameService = self.ctrler.borrowServiceAuth(SpaceCrisisGameService.SOURCE_NAME)
      self.service = gameService as! &SpaceCrisisGameService.Service
    }

    execute {
      self.service.profileSetProperty(identifier: Helper.PlatformIdentity(platform, uid), prop: prop, value: value)
    }
}

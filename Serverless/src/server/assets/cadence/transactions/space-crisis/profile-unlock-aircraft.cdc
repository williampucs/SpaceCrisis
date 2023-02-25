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
  key: String,
) {
    let ctrler: &GameServices.ServicesHQController
    let service: &SpaceCrisisGameService.Service

    prepare(acct: AuthAccount) {
      self.ctrler = acct.borrow<&GameServices.ServicesHQController>(from: GameServices.GameServicesControlerStoragePath)
                ?? panic("Not the service account.")
      let gameService = self.ctrler.borrowServiceAuth(SpaceCrisisGameService.SOURCE_NAME) ?? panic("Failed to load")
      self.service = gameService as! &SpaceCrisisGameService.Service
    }

    execute {
      self.service.profileUnlockAircraft(identifier: Helper.PlatformIdentity(platform, uid), key: key)
    }
}

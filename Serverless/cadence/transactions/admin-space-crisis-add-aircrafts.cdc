// import Helper from "../contracts/Helper.cdc"
// import Interfaces from "../contracts/Interfaces.cdc"
// import PlayerKit from "../contracts/PlayerKit.cdc"
import GameServices from "../contracts/GameServices.cdc"
// import ProfileClaimer from "../contracts/ProfileClaimer.cdc"
// import SpaceCrisisDefination from "../contracts/space-crisis/SpaceCrisisDefination.cdc"
import SpaceCrisisGameService from "../contracts/space-crisis/SpaceCrisisGameService.cdc"
// import SpaceCrisisPlayerProfile from "../contracts/space-crisis/SpaceCrisisPlayerProfile.cdc"

transaction(
  keys: [String]
) {
    let service: &SpaceCrisisGameService.Service

    prepare(acct: AuthAccount) {
      let admin = acct.borrow<&GameServices.ServicesHQAdmin>(from: GameServices.GameServicesAdminStoragePath)
                ?? panic("Not the service account.")
      let gameService = admin.borrowServiceAdmin(SpaceCrisisGameService.SOURCE_NAME)
      self.service = gameService as! &SpaceCrisisGameService.Service
    }

    execute {
      self.service.initializeAircrafts(keys: keys)
    }
}

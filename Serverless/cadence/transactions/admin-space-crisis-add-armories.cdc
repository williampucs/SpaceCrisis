// import Helper from "../contracts/Helper.cdc"
// import Interfaces from "../contracts/Interfaces.cdc"
// import PlayerKit from "../contracts/PlayerKit.cdc"
import GameServices from "../contracts/GameServices.cdc"
// import ProfileClaimer from "../contracts/ProfileClaimer.cdc"
import SpaceCrisisDefinition from "../contracts/space-crisis/SpaceCrisisDefinition.cdc"
import SpaceCrisisGameService from "../contracts/space-crisis/SpaceCrisisGameService.cdc"
// import SpaceCrisisPlayerProfile from "../contracts/space-crisis/SpaceCrisisPlayerProfile.cdc"

transaction(
  keys: [String],
  useNFTs: [Bool],
  levelMaxs: [UFix64],
  levelRatios: [UFix64],
  extra: [String?],
) {
    let service: &SpaceCrisisGameService.Service

    prepare(acct: AuthAccount) {
      let ctrler = acct.borrow<&GameServices.ServicesHQController>(from: GameServices.GameServicesControlerStoragePath)
                ?? panic("Not the service account.")
      let gameService = ctrler.borrowServiceAuth(SpaceCrisisGameService.sourceName) ?? panic("Failed to load")
      self.service = gameService as! &SpaceCrisisGameService.Service
    }

    execute {
      for i, key in keys {
        if useNFTs[i] {
          self.service.setArmory(armory: SpaceCrisisDefinition.NFTArmory(
            key: key,
            max: levelMaxs[i],
            binding: extra[i] ?? panic("missing binding key."),
            ratio: levelRatios[i],
          ))
        } else {
          self.service.setArmory(armory: SpaceCrisisDefinition.PlayerArmory(
            key: key,
            max: levelMaxs[i],
            ratio: levelRatios[i],
          ))
        }
      }
    }
}

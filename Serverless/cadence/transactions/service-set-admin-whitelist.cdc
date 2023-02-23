// import Helper from "../contracts/Helper.cdc"
// import Interfaces from "../contracts/Interfaces.cdc"
// import PlayerKit from "../contracts/PlayerKit.cdc"
import GameServices from "../contracts/GameServices.cdc"
// import ProfileClaimer from "../contracts/ProfileClaimer.cdc"
// import SpaceCrisisDefination from "../contracts/space-crisis/SpaceCrisisDefination.cdc"
// import SpaceCrisisGameService from "../contracts/space-crisis/SpaceCrisisGameService.cdc"
// import SpaceCrisisPlayerProfile from "../contracts/space-crisis/SpaceCrisisPlayerProfile.cdc"

transaction(
    target: Address,
    valid: Bool
) {
    prepare(service: AuthAccount) {
        let service = service.borrow<&GameServices.ServicesHQ>(from: GameServices.GameSerivcesStoragePath)
            ?? panic("Not the service account.")

        service.updateWhitelistFlag(addr: target, flag: valid)
    }
}

// import Helper from "../contracts/Helper.cdc"
// import Interfaces from "../contracts/Interfaces.cdc"
// import PlayerKit from "../contracts/PlayerKit.cdc"
import GameServices from "../contracts/GameServices.cdc"
// import ProfileClaimer from "../contracts/ProfileClaimer.cdc"
// import SpaceCrisisDefinition from "../contracts/space-crisis/SpaceCrisisDefinition.cdc"
// import SpaceCrisisGameService from "../contracts/space-crisis/SpaceCrisisGameService.cdc"
// import SpaceCrisisPlayerProfile from "../contracts/space-crisis/SpaceCrisisPlayerProfile.cdc"

transaction {

    prepare(service: AuthAccount, acct: AuthAccount) {
        assert(
            acct.borrow<&GameServices.ServicesHQController>(from: GameServices.GameServicesControlerStoragePath) == nil,
            message: "Controller resource should be nil"
        )

        let service = service.borrow<&GameServices.ServicesHQ>(from: GameServices.GameSerivcesStoragePath)
            ?? panic("Not the service account.")

        acct.save(<- service.createHQController(), to: GameServices.GameServicesControlerStoragePath)
    }
}

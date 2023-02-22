import Interfaces from "../Interfaces.cdc"
import GameServices from "../GameServices.cdc"
import SpaceCrisisPlayerProfile from "./SpaceCrisisPlayerProfile.cdc"

pub contract SpaceCrisisGameService {
  pub let SOURCE_NAME: String

  pub resource Service: Interfaces.GameServicePublic, Interfaces.GameServiceAdmin {

    init() {
      // TODO
    }

    pub fun getSource(): String {
      return SpaceCrisisGameService.SOURCE_NAME
    }

    access(account) fun initialize() {
      // TODO
    }
    access(account) fun createProfile(platform: String, uid: String): @{Interfaces.ProfilePublic, Interfaces.ProfilePrivate} {
      return <- SpaceCrisisPlayerProfile.createProfile(platform: platform, uid: uid)
    }

    access(account) fun borrowServiceAdmin(): auth &{Interfaces.GameServiceAdmin} {
      return &self as auth &{Interfaces.GameServiceAdmin}
    }
  }

  init() {
    self.SOURCE_NAME = "SpaceCrisis"

    let hq = GameServices.borrowServiceHQPriv()
    hq.attachService(service: <- create Service())
  }
}

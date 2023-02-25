import Helper from "../../../../../../cadence/contracts/Helper.cdc"
// import Interfaces from "../../../../../../cadence/contracts/Interfaces.cdc"
// import PlayerKit from "../../../../../../cadence/contracts/PlayerKit.cdc"
// import GameServices from "../../../../../../cadence/contracts/GameServices.cdc"
// import ProfileClaimer from "../../../../../../cadence/contracts/ProfileClaimer.cdc"
import SpaceCrisisDefination from "../../../../../../cadence/contracts/space-crisis/SpaceCrisisDefination.cdc"
import SpaceCrisisGameService from "../../../../../../cadence/contracts/space-crisis/SpaceCrisisGameService.cdc"
// import SpaceCrisisPlayerProfile from "../../../../../../cadence/contracts/space-crisis/SpaceCrisisPlayerProfile.cdc"

pub fun main(): ServiceInfo {
  let service = SpaceCrisisGameService.borrowServicePublic()
  let keys = service.getArmories()
  let availableArmories: [{SpaceCrisisDefination.ArmoryInterface}] = []
  for key in keys {
    if let armory = service.getArmory(key: key) {
      availableArmories.append(armory)
    }
  }
  return ServiceInfo(
    name: SpaceCrisisGameService.SOURCE_NAME,
    availableAircrafts: service.getAircrafts(),
    availableArmories: availableArmories
  )
}

pub struct ServiceInfo {
  pub let name: String
  pub let availableArmories: [{SpaceCrisisDefination.ArmoryInterface}]
  pub let availableAircrafts: [String]

  init(
    name: String,
    availableAircrafts: [String],
    availableArmories: [{SpaceCrisisDefination.ArmoryInterface}],
  ) {
    self.name = name
    self.availableArmories = availableArmories
    self.availableAircrafts = availableAircrafts
  }
}

import Helper from "../../../../../../cadence/contracts/Helper.cdc"
// import Interfaces from "../../../../../../cadence/contracts/Interfaces.cdc"
// import PlayerKit from "../../../../../../cadence/contracts/PlayerKit.cdc"
// import GameServices from "../../../../../../cadence/contracts/GameServices.cdc"
// import ProfileClaimer from "../../../../../../cadence/contracts/ProfileClaimer.cdc"
import SpaceCrisisDefinition from "../../../../../../cadence/contracts/space-crisis/SpaceCrisisDefinition.cdc"
import SpaceCrisisGameService from "../../../../../../cadence/contracts/space-crisis/SpaceCrisisGameService.cdc"
import SpaceCrisisPlayerProfile from "../../../../../../cadence/contracts/space-crisis/SpaceCrisisPlayerProfile.cdc"

pub fun main(
  platform: String,
  uid: String,
): ProfileData? {
  let identifier = Helper.PlatformIdentity(platform, uid)
  if let profile = SpaceCrisisPlayerProfile.borrowProfilePublic(identifier) {
    let service = SpaceCrisisGameService.borrowServicePublic()
    let equipments: {String: SpaceCrisisDefinition.EquipmentStatus} = service.getProfileEquipments(identifier: identifier)
    return ProfileData(
      userId: profile.getUserId(),
      isSelfAttached: profile.isAttached,
      ownerAddress: profile.isAttached ? profile.owner!.address : nil,
      info: profile.bindedPlatformInfo(),
      unlockedAircrafts: profile.getUnlockedAircrafts(),
      currentAircraft: profile.getCurrentAircraft(),
      equipments: equipments,
    )
  }
  return nil
}

pub struct ProfileData {
  pub let userId: String
  pub let isSelfAttached: Bool
  pub let ownerAddress: Address?
  pub let info: Helper.PlatformInfo
  pub let unlockedAircrafts: [String]
  pub let currentAircraft: String?
  pub let equipments: {String: SpaceCrisisDefinition.EquipmentStatus}

  init(
    userId: String,
    isSelfAttached: Bool,
    ownerAddress: Address?,
    info: Helper.PlatformInfo,
    unlockedAircrafts: [String],
    currentAircraft: String?,
    equipments: {String: SpaceCrisisDefinition.EquipmentStatus},
  ) {
    self.userId = userId
    self.isSelfAttached = isSelfAttached
    self.ownerAddress = ownerAddress
    self.info = info
    self.unlockedAircrafts = unlockedAircrafts
    self.currentAircraft = currentAircraft
    self.equipments = equipments
  }
}

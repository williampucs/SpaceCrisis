import Helper from "../Helper.cdc"
import Interfaces from "../Interfaces.cdc"
import GameServices from "../GameServices.cdc"
import SpaceCrisisPlayerProfile from "./SpaceCrisisPlayerProfile.cdc"
import SpaceCrisisDefinition from "./SpaceCrisisDefinition.cdc"

pub contract SpaceCrisisGameService {
  // events
  pub event ContractInitialized()

  pub event SetArmory(key: String, type: Type, info: String, maxLevel: UFix64)
  pub event InitAircrafts(keys: [String])
  pub event SetAircraftProperties(key: String, prop: String)

  // members
  pub let sourceName: String

  // resources

  pub resource interface ServicePublic {
    pub fun getArmories(): [String]
    pub fun getArmory(key: String): {SpaceCrisisDefinition.ArmoryInterface}?
    pub fun getAircrafts(): [String]
    pub fun getAircraftProperties(key: String): {String: AnyStruct}

    pub fun getProfileEquipments(identifier: Helper.PlatformIdentity): {String: SpaceCrisisDefinition.EquipmentStatus}
  }

  pub resource Service: ServicePublic, Interfaces.GameServicePublic, Interfaces.GameServiceAdmin {
    access(self) let armories: {String: {SpaceCrisisDefinition.ArmoryInterface}}
    access(self) let aircrafts: {String: SpaceCrisisDefinition.AircraftDefination}

    init() {
      self.armories = {}
      self.aircrafts = {}
    }

    pub fun getSource(): String {
      return SpaceCrisisGameService.sourceName
    }

    access(account) fun initialize() {
      // NOTHING
    }

    access(account) fun createProfile(platform: String, uid: String): @{Interfaces.ProfilePublic, Interfaces.ProfilePrivate} {
      return <- SpaceCrisisPlayerProfile.createProfile(platform: platform, uid: uid)
    }

    access(account) fun borrowServiceAdmin(): auth &{Interfaces.GameServiceAdmin} {
      return &self as auth &{Interfaces.GameServiceAdmin}
    }

    // -- readonly methods ---
    pub fun getArmories(): [String] {
      return self.armories.keys
    }

    pub fun getArmory(key: String): {SpaceCrisisDefinition.ArmoryInterface}? {
      return self.armories[key]
    }

    pub fun getAircrafts(): [String] {
      return self.aircrafts.keys
    }

    pub fun getAircraftProperties(key: String): {String: AnyStruct} {
      return self.aircrafts[key]!.getProperties()
    }

    pub fun getProfileEquipments(identifier: Helper.PlatformIdentity): {String: SpaceCrisisDefinition.EquipmentStatus} {
      let allTypes = self.armories.keys
      let ret: {String: SpaceCrisisDefinition.EquipmentStatus} = {}
      let profileRef = SpaceCrisisPlayerProfile.borrowProfilePublic(identifier)

      for key in allTypes {
        if let armoryRef = &self.armories[key] as &{SpaceCrisisDefinition.ArmoryInterface}? {
          let level = armoryRef.getEquipmentLevel(identifier)
          ret[key] = SpaceCrisisDefinition.EquipmentStatus(key, enabled: level != 0.0, level: level)
        }
      }
      return ret
    }

    // -- writable methods ---

    pub fun setArmory(armory: {SpaceCrisisDefinition.ArmoryInterface}) {
      pre {
        armory.checkValid(): "Binding Collection not exist"
      }
      self.armories[armory.key] = armory

      emit SetArmory(
        key: armory.key,
        type: armory.getType(),
        info: armory.getInfo(),
        maxLevel: armory.getMaxLevel()
      )
    }

    pub fun initializeAircrafts(keys: [String]) {
      for key in keys {
        assert(self.aircrafts[key] == nil, message: "Exists aircraft:".concat(key))
        self.aircrafts[key] = SpaceCrisisDefinition.AircraftDefination(key: key)
      }

      emit InitAircrafts(
        keys: keys
      )
    }

    pub fun setAircraftProperties(key: String, prop: String, value: AnyStruct) {
      let aircraft = self.aircrafts[key] ?? panic("Failed to load aircraft")
      aircraft.setProperty(prop: prop, value: value)

      emit SetAircraftProperties(
        key: key,
        prop: prop
      )
    }

    // --- profile control methods ----

    pub fun profileUnlockAircraft(identifier: Helper.PlatformIdentity, key: String) {
      let profile = GameServices.borrowProfileAuth(SpaceCrisisPlayerProfile.sourceName, platform: identifier.platform, uid: identifier.uid)
        ?? panic("Failed to load profile")
      let authRef = profile as! &SpaceCrisisPlayerProfile.Profile
      let unlocked = authRef.getUnlockedAircrafts()
      if !unlocked.contains(key) {
        authRef.unlockAircraft(key: key)
      }
      authRef.setCurrentAircraft(key: key)
    }

    pub fun profileSetCurrentAircraft(identifier: Helper.PlatformIdentity, key: String) {
      let profile = GameServices.borrowProfileAuth(SpaceCrisisPlayerProfile.sourceName, platform: identifier.platform, uid: identifier.uid)
        ?? panic("Failed to load profile")
      let authRef = profile as! &SpaceCrisisPlayerProfile.Profile
      authRef.setCurrentAircraft(key: key)
    }

    pub fun profileSetProperty(identifier: Helper.PlatformIdentity, prop: String, value: UFix64) {
      let profile = GameServices.borrowProfileAuth(SpaceCrisisPlayerProfile.sourceName, platform: identifier.platform, uid: identifier.uid)
        ?? panic("Failed to load profile")
      let authRef = profile as! &SpaceCrisisPlayerProfile.Profile
      authRef.setProperty(prop: prop, value: value)
    }
  }

  pub fun borrowServicePublic(): &Service{ServicePublic, Interfaces.GameServicePublic} {
    let service = GameServices.borrowServiceAuth(self.sourceName) ?? panic("Failed to load service.")
    return service as! &Service{ServicePublic, Interfaces.GameServicePublic}
  }

  init() {
    self.sourceName = "SpaceCrisis"

    GameServices.attachService(service: <- create Service())

    emit ContractInitialized()
  }
}

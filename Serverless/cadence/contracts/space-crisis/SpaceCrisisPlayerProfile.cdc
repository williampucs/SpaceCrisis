import Helper from "../Helper.cdc"
import Interfaces from "../Interfaces.cdc"
import GameServices from "../GameServices.cdc"

pub contract SpaceCrisisPlayerProfile {
  // events
  pub event ContractInitialized()

  pub event UnlockAircraft(userId: String, key: String)
  pub event SetProperty(userId: String, prop: String, value: UFix64)

  // members
  pub let SOURCE_NAME: String

  pub resource interface ProfilePublic {
    pub fun getUnlockedAircrafts(): [String]
    pub fun getCurrentAircraft(): String?
    pub fun getProperties(): {String: UFix64}
  }

  pub resource Profile: ProfilePublic, Interfaces.ProfilePublic, Interfaces.ProfilePrivate {
    pub var isAttached: Bool
    access(self) var info: Helper.PlatformInfo
    access(self) var currentAircraft: String?
    access(self) let unlockedAircrafts: {String: Bool}
    access(self) let properties: {String: UFix64}

    init(platform: String, uid: String) {
      self.isAttached = false
      self.info = Helper.PlatformInfo(platform: platform, uid: uid, display: nil)
      self.currentAircraft = nil
      self.unlockedAircrafts = {}
      self.properties = {}
    }

    pub fun getSource(): String {
      return SpaceCrisisPlayerProfile.SOURCE_NAME
    }

    pub fun bindedPlatformInfo(): Helper.PlatformInfo {
      return self.info
    }

    pub fun getUnlockedAircrafts(): [String] {
      let ret: [String] = []
      for key in self.unlockedAircrafts.keys {
        if self.unlockedAircrafts[key] == true {
          ret.append(key)
        }
      }
      return ret
    }

    pub fun getCurrentAircraft(): String? {
      return self.currentAircraft
    }

    pub fun getProperties(): {String: UFix64} {
      return self.properties
    }

    access(account) fun unlockAircraft(key: String) {
      self.unlockedAircrafts[key] = true

      emit UnlockAircraft(
        userId: self.getUserId(),
        key: key,
      )
    }

    access(account) fun setProperty(prop: String, value: UFix64) {
      self.properties[prop] = value

      emit SetProperty(
        userId: self.getUserId(),
        prop: prop,
        value: value,
      )
    }
  }

  pub fun borrowProfilePublic(_ identifier: Helper.PlatformIdentity): &Profile{ProfilePublic, Interfaces.ProfilePublic}? {
    let profile = GameServices.borrowProfileAuth(self.SOURCE_NAME, platform: identifier.platform, uid: identifier.uid)
    if profile == nil {
      return nil
    }
    return profile as! &Profile{ProfilePublic, Interfaces.ProfilePublic}?
  }

  access(account) fun createProfile(platform: String, uid: String): @Profile {
    return <- create Profile(platform: platform, uid: uid)
  }

  init() {
    self.SOURCE_NAME = "SpaceCrisis"

    emit ContractInitialized()
  }
}

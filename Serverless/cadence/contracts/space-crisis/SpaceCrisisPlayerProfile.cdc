import Interfaces from "../Interfaces.cdc"
import Helper from "../Helper.cdc"

pub contract SpaceCrisisPlayerProfile {
  pub let SOURCE_NAME: String

  pub resource Profile: Interfaces.ProfilePublic, Interfaces.ProfilePrivate {
    access(self) var info: Helper.PlatformInfo

    init(platform: String, uid: String) {
      self.info = Helper.PlatformInfo(platform: platform, uid: uid, display: nil)
    }

    pub fun getSource(): String {
      return SpaceCrisisPlayerProfile.SOURCE_NAME
    }

    pub fun bindedPlatformInfo(): Helper.PlatformInfo {
      return self.info
    }
  }

  access(account) fun createProfile(platform: String, uid: String): @Profile {
    return <- create Profile(platform: platform, uid: uid)
  }

  init() {
    self.SOURCE_NAME = "SpaceCrisis"
  }
}

import MetadataViews from "./deps/MetadataViews.cdc"

pub contract Helper {

  pub struct PlatformIdentity {
    pub let platform: String
    pub let uid: String

    init(_ platform: String, _ uid: String) {
      self.platform = platform
      self.uid = uid
    }

    pub fun toString(): String {
      return self.platform.concat("-").concat(self.uid)
    }
  }

  pub struct PlatformInfo {
    pub let identity: PlatformIdentity
    pub let display: MetadataViews.Display?

    init(platform: String, uid: String, display: MetadataViews.Display?) {
      self.identity = PlatformIdentity(platform, uid)
      self.display = display
    }
  }
}

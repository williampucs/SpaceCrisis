import MetadataViews from "./deps/MetadataViews.cdc"
import Helper from "./Helper.cdc"
import Interfaces from "./Interfaces.cdc"

pub contract PlayerKit {
  pub let PlayerKitStoragePath: StoragePath;
  pub let PlayerKitPublicPath: PublicPath;
  pub let PlayerKitPrivatePath: PrivatePath;

  // Events

  pub event ContractInitialized()

  pub event ProfileAttached(source: String, address: Address, uuid: UInt64)
  pub event ProfileRevoked(source: String, address: Address, uuid: UInt64)

  pub event PlayerUpsertIdentity(address: Address, userId: String, name: String?, image: String?)

  // States

  pub var totalProfiles: UInt64
  access(contract) let platformMapping: {String: Address}

  // Functionality

  pub resource interface ProfliesPublic {
    pub fun getIdentities(): [Helper.PlatformInfo]
    pub fun getIdentity(platform: String): Helper.PlatformInfo?

    pub fun borrowProfile(_ source: String): &{Interfaces.ProfilePublic}?
    access(account) fun borrowProfileAuth(_ source: String): auth &{Interfaces.ProfilePublic, Interfaces.ProfilePrivate}?
  }

  pub resource interface ProfilesPrivate {
    pub fun upsertIdentity(info: Helper.PlatformInfo)
    pub fun attachProfile(profile: @{Interfaces.ProfilePublic, Interfaces.ProfilePrivate})
    pub fun revokeProfile(_ source: String): @{Interfaces.ProfilePublic}
  }

  pub resource Profiles: ProfliesPublic, ProfilesPrivate {
    access(self) var linkedIdentities: {String: Helper.PlatformInfo}
    access(self) let profiles: @{String: {Interfaces.ProfilePublic, Interfaces.ProfilePrivate}}

    init() {
      self.linkedIdentities = {}
      self.profiles <- {}

      PlayerKit.totalProfiles = PlayerKit.totalProfiles + 1
    }

    destroy() {
      destroy self.profiles
    }

    // ---- public - readonly ----

    pub fun getIdentities(): [Helper.PlatformInfo] {
      return self.linkedIdentities.values
    }

    pub fun getIdentity(platform: String): Helper.PlatformInfo? {
      return self.linkedIdentities[platform]
    }

    pub fun borrowProfile(_ source: String): &{Interfaces.ProfilePublic}? {
      return &self.profiles[source] as &{Interfaces.ProfilePublic}?
    }

    access(account) fun borrowProfileAuth(_ source: String): auth &{Interfaces.ProfilePublic, Interfaces.ProfilePrivate}? {
      return &self.profiles[source] as auth &{Interfaces.ProfilePublic, Interfaces.ProfilePrivate}?
    }

    // ---- private or writable ----
    pub fun upsertIdentity(info: Helper.PlatformInfo) {
      let profileAddr = self.owner?.address ?? panic("Owner not exist")
      let platform = info.identity.platform
      let uid = Helper.PlatformIdentity(platform, info.identity.uid).toString()

      assert(
        PlayerKit.platformMapping[uid] == nil || PlayerKit.platformMapping[uid] == profileAddr,
        message: "Platfrom UID registered"
      )
      PlayerKit.platformMapping[uid] = profileAddr
      self.linkedIdentities[platform] = info

      emit PlayerUpsertIdentity(
        address: profileAddr,
        userId: info.identity.toString(),
        name: info.display?.name,
        image: info.display?.thumbnail?.uri()
      )
    }

    pub fun attachProfile(profile: @{Interfaces.ProfilePublic, Interfaces.ProfilePrivate}) {
      pre {
        self.profiles[profile.getSource()] == nil: "Profile exists"
      }
      let sourceName = profile.getSource()
      let bindedPlatform = profile.bindedPlatformInfo()
      if let linkedInfo = &self.linkedIdentities[bindedPlatform.identity.platform] as &Helper.PlatformInfo? {
        assert(
          linkedInfo.identity.platform == bindedPlatform.identity.platform && linkedInfo.identity.uid == bindedPlatform.identity.uid,
          message: "Platform identity is miss-matched"
        )
      } else {
        self.upsertIdentity(info: Helper.PlatformInfo(
          platform: bindedPlatform.identity.platform,
          uid: bindedPlatform.identity.platform,
          display: bindedPlatform.display
        ))
      }

      let ref = &profile as &{Interfaces.ProfilePublic, Interfaces.ProfilePrivate}
      self.profiles[sourceName] <-! profile
      ref.setAttached(true)

      emit ProfileAttached(source: sourceName, address: self.owner!.address, uuid: ref.uuid)
    }

    pub fun revokeProfile(_ source: String): @{Interfaces.ProfilePublic} {
      let profile <- self.profiles.remove(key: source) ?? panic("Profile not exist")
      profile.setAttached(false)

      emit ProfileRevoked(source: source, address: self.owner!.address, uuid: profile.uuid)

      return <- profile
    }

    // ---- internal ----

  }

  // ---- public methods ----

  pub fun createProfiles(): @Profiles {
    return <- create Profiles()
  }

  pub fun borrowProfilesPublic(_ acct: Address): &Profiles{ProfliesPublic}? {
    return getAccount(acct)
      .getCapability<&Profiles{ProfliesPublic}>(self.PlayerKitPublicPath)
      .borrow()
  }

  pub fun getPlatformLinkedAddress(platform: String, uid: String): Address? {
    let uid = Helper.PlatformIdentity(platform, uid).toString()
    return self.platformMapping[uid]
  }

  access(account) fun borrowProfileByPlatform(platform: String, uid: String, source: String): auth &{Interfaces.ProfilePublic, Interfaces.ProfilePrivate}? {
    if let address = self.getPlatformLinkedAddress(platform: platform, uid: uid) {
      if let profiles = self.borrowProfilesPublic(address) {
        return profiles.borrowProfileAuth(source)
      }
    }
    return nil
  }

  // Initialize

  init() {
    self.totalProfiles = 0

    self.PlayerKitStoragePath = /storage/ThePlayerKitPathV1
    self.PlayerKitPublicPath = /public/ThePlayerKitPathV1
    self.PlayerKitPrivatePath = /private/ThePlayerKitPathV1

    self.platformMapping = {}

    emit ContractInitialized()
  }
}

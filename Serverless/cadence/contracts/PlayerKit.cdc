import MetadataViews from "./deps/MetadataViews.cdc"
import ProfileInterface from "./ProfileInterface.cdc"

pub contract PlayerKit {

    pub let PlayerKitStoragePath: StoragePath;
    pub let PlayerKitPublicPath: PublicPath;

    // Events

    pub event ContractInitialized()

    pub event ProfileAttached(source: String, address: Address, profileUid: UInt64)
    pub event ProfileRevoked(source: String, address: Address, profileUid: UInt64)

    // States

    pub var totalProfiles: UInt64

    // Functionality

    pub resource interface ProfliesPublic {

    }

    pub resource Profiles: ProfliesPublic {
      access(contract) let profiles: @{String: {ProfileInterface.ProfilePublic}}

      init() {
        self.profiles <- {}

        PlayerKit.totalProfiles = PlayerKit.totalProfiles + 1
      }

      destroy() {
        destroy self.profiles
      }

      // ---- public - readonly ----

      // ---- public - writable ----

      access(account) fun attachProfile(profile: @{ProfileInterface.ProfilePublic}) {
        pre {
          self.profiles[profile.getSource()] == nil: "Profile exists"
        }
        let sourceName = profile.getSource()
        let uuid = profile.uuid
        self.profiles[sourceName] <-! profile

        emit ProfileAttached(source: sourceName, address: self.owner!.address, profileUid: uuid)
      }

      // ---- writable ----

      pub fun revokeProfile(sourceName: String): @{ProfileInterface.ProfilePublic} {
        let profile <- self.profiles.remove(key: sourceName) ?? panic("Profile not exist")
        let uuid = profile.uuid

        emit ProfileRevoked(source: sourceName, address: self.owner!.address, profileUid: uuid)

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

    // Initialize

    init() {
      self.totalProfiles = 0

      self.PlayerKitStoragePath = /storage/ThePlayerKitPathV1
      self.PlayerKitPublicPath = /public/ThePlayerKitPathV1

      emit ContractInitialized()
    }
}

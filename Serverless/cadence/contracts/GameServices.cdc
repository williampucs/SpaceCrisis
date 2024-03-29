import Helper from "./Helper.cdc"
import Interfaces from "./Interfaces.cdc"
import PlayerKit from "./PlayerKit.cdc"

pub contract GameServices {
  pub let GameSerivcesStoragePath: StoragePath;
  pub let GameSerivcesPublicPath: PublicPath;
  pub let GameSerivcesPrivatePath: PrivatePath;

  pub let GameServicesAdminStoragePath: StoragePath;
  pub let GameServicesControlerStoragePath: StoragePath;

  // Events

  pub event ContractInitialized()

  pub event ServiceAttached(source: String)

  pub event ProfileCreated(source: String, platform: String, uid: String)
  pub event ProfileClaimed(source: String, platform: String, uid: String)

  // service events
  pub event ServicesHQWhitelistUpdated(target: Address, flag: Bool)
  pub event ServicesHQAdminResourceClaimed(claimer: Address, uuid: UInt64)

  // Functionality

  pub resource interface ServicesHQPublic {
    // Admin related
    pub fun isAdminValid(_ addr: Address): Bool
    pub fun claimHQAdmin(claimer: &PlayerKit.Profiles{PlayerKit.ProfilesPrivate}): @ServicesHQAdmin
    // basic info
    pub fun getRegisteredServices(): [String]
    pub fun isGuest(_ source: String, identifier: Helper.PlatformIdentity): Bool
    // borrow
    pub fun borrowService(_ source: String): &{Interfaces.GameServicePublic}?

    // only can be claim by PlayerKit
    access(account) fun claimProfile(_ source: String, identifier: Helper.PlatformIdentity): @{Interfaces.ProfilePublic, Interfaces.ProfilePrivate}
  }

  pub resource interface ServicesHQPrivate {
    // borrow
    pub fun borrowServiceAuth(_ source: String): auth &{Interfaces.GameServicePublic}?
    // only can be invoked by services
    pub fun attachService(service: @{Interfaces.GameServicePublic})
  }

  pub resource ServicesHQ: ServicesHQPublic, ServicesHQPrivate {
    access(self) let adminWhitelist: {Address: Bool}
    // stores
    access(self) let services: @{String: {Interfaces.GameServicePublic}}
    access(contract) let guestProfiles: @{String: {String: {Interfaces.ProfilePublic, Interfaces.ProfilePrivate}}}

    init() {
      self.adminWhitelist = {}
      self.services <- {}
      self.guestProfiles <- {}
    }

    destroy() {
      destroy self.services
      destroy self.guestProfiles
    }

    // ---- factory ----

    pub fun claimHQAdmin(claimer: &PlayerKit.Profiles{PlayerKit.ProfilesPrivate}): @ServicesHQAdmin {
        let claimerAddr = claimer.owner?.address ?? panic("Failed to load profile")
        assert(self.isAdminValid(claimerAddr), message: "Admin is invalid")

        let admin <- create ServicesHQAdmin()
        emit ServicesHQAdminResourceClaimed(claimer: claimerAddr, uuid: admin.uuid)

        return <- admin
    }

    pub fun createHQController(): @ServicesHQController {
      return <- create ServicesHQController()
    }

    // ---- public - readonly ----

    pub fun isAdminValid(_ addr: Address): Bool {
      return self.adminWhitelist[addr] ?? false
    }

    pub fun borrowService(_ source: String): &{Interfaces.GameServicePublic}? {
      return &self.services[source] as &{Interfaces.GameServicePublic}?
    }

    pub fun getRegisteredServices(): [String] {
      return self.services.keys
    }

    pub fun isGuest(_ source: String, identifier: Helper.PlatformIdentity): Bool {
      let guests = self.borrowGuestProfiles(source)
      return guests[identifier.toString()] != nil
    }

    // ---- writable ----

    pub fun updateWhitelistFlag(addr: Address, flag: Bool) {
      self.adminWhitelist[addr] = flag

      emit ServicesHQWhitelistUpdated(
        target: addr,
        flag: flag
      )
    }

    pub fun attachService(service: @{Interfaces.GameServicePublic}) {
      pre {
        self.services[service.getSource()] == nil: "Service exists"
      }
      let ref = &service as &{Interfaces.GameServicePublic}
      let source = ref.getSource()

      self.services[source] <-! service
      ref.initialize()

      // init guest profiles
      self.guestProfiles[source] <-! {}

      emit ServiceAttached(source: source)
    }

    access(account) fun claimProfile(_ source: String, identifier: Helper.PlatformIdentity): @{Interfaces.ProfilePublic, Interfaces.ProfilePrivate} {
      let guests = self.borrowGuestProfiles(source)
      let userId = identifier.toString()
      if guests[userId] == nil {
        panic("Profile not exists")
      }

      let profile <- guests.remove(key: userId) ?? panic("Profile not exist")

      emit ProfileClaimed(source: source, platform: identifier.platform, uid: identifier.uid)

      return <- profile
    }

    // ---- borrow private ----

    pub fun borrowServiceAuth(_ source: String): auth &{Interfaces.GameServicePublic}? {
      return &self.services[source] as auth &{Interfaces.GameServicePublic}?
    }

    // ---- interface ----
    access(contract) fun borrowGuestProfiles(_ source: String): &{String: {Interfaces.ProfilePublic, Interfaces.ProfilePrivate}} {
      return &self.guestProfiles[source] as &{String: {Interfaces.ProfilePublic, Interfaces.ProfilePrivate}}?
        ?? panic("Invalid service source.")
    }
  }

  pub resource ServicesHQAdmin {
    pub fun borrowServiceAdmin(_ source: String): auth &{Interfaces.GameServiceAdmin} {
      let owner = self.owner?.address ?? panic("Invalid owner.")
      let hq = GameServices.borrowServiceHQPriv()
      assert(hq.isAdminValid(owner), message: "current owner is not an admin.")
      let service = hq.borrowService(source) ?? panic("Invalid service source.")
      return service.borrowServiceAdmin()
    }
  }

  pub resource ServicesHQController {

    pub fun borrowServiceAuth(_ source: String): auth &{Interfaces.GameServicePublic}? {
      let hq = GameServices.borrowServiceHQPriv()
      return hq.borrowServiceAuth(source)
    }

    pub fun createProfile(_ source: String, platform: String, uid: String): auth &{Interfaces.ProfilePrivate} {
      let hq = GameServices.borrowServiceHQPriv()
      let service = hq.borrowService(source) ?? panic("Invalid service source.")
      let profilesRef = hq.borrowGuestProfiles(source)

      let identifier = Helper.PlatformIdentity(platform, uid)
      assert(GameServices.borrowProfileAuth(source, platform: platform, uid: uid) == nil, message: "Profile exists.")

      let userId = identifier.toString()
      profilesRef[userId] <-! service.createProfile(platform: platform, uid: uid)

      emit ProfileCreated(source: source, platform: platform, uid: uid)

      return &profilesRef[userId] as auth &{Interfaces.ProfilePrivate}? ?? panic("Impossible")
    }

    pub fun borrowProfileAuth(_ source: String, platform: String, uid: String): auth &{Interfaces.ProfilePublic, Interfaces.ProfilePrivate}? {
      return GameServices.borrowProfileAuth(source, platform: platform, uid: uid)
    }
  }

  // ---- methods ----

  pub fun borrowServiceHQ(): &ServicesHQ{ServicesHQPublic} {
    return self.account.getCapability<&ServicesHQ{ServicesHQPublic}>(self.GameSerivcesPublicPath).borrow() ?? panic("Failed to borrow.")
  }

  access(account) fun attachService(service: @{Interfaces.GameServicePublic}) {
    let hq = self.borrowServiceHQPriv()
    hq.attachService(service: <-service)
  }

  access(account) fun borrowServiceAuth(_ source: String): auth &{Interfaces.GameServicePublic}? {
    let hq = self.borrowServiceHQPriv()
    return hq.borrowServiceAuth(source)
  }

  access(account) fun borrowProfileAuth(_ source: String, platform: String, uid: String):  auth &{Interfaces.ProfilePublic, Interfaces.ProfilePrivate}? {
    // try load from guest first
    let hq = self.borrowServiceHQPriv()
    let service = hq.borrowService(source) ?? panic("Invalid service source.")
    let guests = hq.borrowGuestProfiles(source)

    let userId = Helper.PlatformIdentity(platform, uid).toString()
    if guests[userId] != nil {
      return &guests[userId] as auth &{Interfaces.ProfilePublic, Interfaces.ProfilePrivate}?
    }

    // try load from player kit
    return PlayerKit.borrowProfileByPlatform(platform: platform, uid: uid, source: source)
  }

  access(contract) fun borrowServiceHQPriv(): &ServicesHQ {
    return self.account.borrow<&ServicesHQ>(from: self.GameSerivcesStoragePath) ?? panic("Failed to borrow")
  }

  init() {
    self.GameSerivcesStoragePath = /storage/TheGameSerivcesPath_V1
    self.GameSerivcesPublicPath = /public/TheGameSerivcesPath_V1
    self.GameSerivcesPrivatePath = /private/TheGameSerivcesPath_V1

    self.GameServicesAdminStoragePath = /storage/TheGameSerivcesAdminPath_V1
    self.GameServicesControlerStoragePath = /storage/TheGameSerivcesControlerPath_V1

    self.account.save(<- create ServicesHQ(), to: self.GameSerivcesStoragePath)
    self.account.link<&ServicesHQ{ServicesHQPublic}>(self.GameSerivcesPublicPath, target: self.GameSerivcesStoragePath)
    self.account.link<&ServicesHQ{ServicesHQPrivate}>(self.GameSerivcesPrivatePath, target: self.GameSerivcesStoragePath)

    self.account.save(<- create ServicesHQController(), to: self.GameServicesControlerStoragePath)

    emit ContractInitialized()
  }
}

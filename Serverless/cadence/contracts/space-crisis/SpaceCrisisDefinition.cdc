import NFTCatalog from "../deps/NFTCatalog.cdc"
import NFTRetrieval from "../deps/NFTRetrieval.cdc"
import MetadataViews from "../deps/MetadataViews.cdc"
import Helper from "../Helper.cdc"
import SpaceCrisisPlayerProfile from "./SpaceCrisisPlayerProfile.cdc"

pub contract SpaceCrisisDefinition {

  pub struct interface ArmoryInterface {
    pub let key: String

    pub fun getMaxLevel(): UFix64
    pub fun getEquipmentLevel(_ identifier: Helper.PlatformIdentity): UFix64

    pub fun checkValid(): Bool
    pub fun getInfo(): String
  }

  pub struct NFTArmory: ArmoryInterface {
    pub let key: String
    pub let levelMax: UFix64
    pub let bindingCollectionIdentifier: String
    pub let levelRatio: UFix64

    init(
      key: String,
      max: UFix64,
      binding: String,
      ratio: UFix64,
    ) {
      self.key = key
      self.levelMax = max
      self.bindingCollectionIdentifier = binding
      self.levelRatio = ratio
    }

    pub fun checkValid(): Bool {
      let nftInfo = NFTCatalog.getCatalogEntry(collectionIdentifier: self.bindingCollectionIdentifier)
      return nftInfo != nil
    }

    pub fun getInfo(): String {
      return "NFT Armory: "
        .concat(self.key)
        .concat(", identifier:").concat(self.bindingCollectionIdentifier)
        .concat("(x ").concat(self.levelRatio.toString()).concat(")")
    }

    pub fun getMaxLevel(): UFix64 {
      return self.levelMax
    }

    pub fun getEquipmentLevel(_ identifier: Helper.PlatformIdentity): UFix64 {
      let profileRef = SpaceCrisisPlayerProfile.borrowProfilePublic(identifier)
        ?? panic("Failed to load profile by identifier:".concat(identifier.toString()))
      if !profileRef.isAttached {
        return 0.0
      }

      let address = profileRef.owner?.address ?? panic("Failed to load owner address")
      let nftInfo = NFTCatalog.getCatalogEntry(collectionIdentifier: self.bindingCollectionIdentifier) ?? panic("Failed to load NFT Metadata")
      let cap = getAccount(address).getCapability<&AnyResource{MetadataViews.ResolverCollection}>(nftInfo.collectionData.publicPath)
      let nftCount = NFTRetrieval.getNFTCountFromCap(collectionIdentifier: self.bindingCollectionIdentifier, collectionCap: cap)
      if nftCount == 0 {
        return 0.0
      }
      let level = UFix64(nftCount) * self.levelRatio
      return level < self.levelMax ? level : self.levelMax
    }
  }

  pub struct PlayerArmory: ArmoryInterface {
    pub let key: String
    pub let levelMax: UFix64
    pub let levelRatio: UFix64

    init(
      key: String,
      max: UFix64,
      ratio: UFix64,
    ) {
      self.key = key
      self.levelMax = max
      self.levelRatio = ratio
    }

    pub fun checkValid(): Bool {
      return true
    }

    pub fun getInfo(): String {
      return "Player Armory: "
        .concat(self.key)
        .concat("(x ").concat(self.levelRatio.toString()).concat(")")
    }

    pub fun getMaxLevel(): UFix64 {
      return self.levelMax
    }

    pub fun getEquipmentLevel(_ identifier: Helper.PlatformIdentity): UFix64 {
      let profileRef = SpaceCrisisPlayerProfile.borrowProfilePublic(identifier)
        ?? panic("Failed to load profile by identifier:".concat(identifier.toString()))

      let properties = profileRef.getProperties()
      let level = (properties[self.key] ?? 0.0) * self.levelRatio
      return level < self.levelMax ? level : self.levelMax
    }
  }

  pub struct AircraftDefination {
    pub let key: String
    access(self) let properties: {String: AnyStruct}

    init(key: String) {
      self.key = key
      self.properties = {}
    }

    pub fun getProperty(prop: String): AnyStruct? {
      return self.properties[prop]
    }

    pub fun getProperties(): {String: AnyStruct} {
      return self.properties
    }

    pub fun setProperty(prop: String, value: AnyStruct) {
      self.properties[prop] = value
    }
  }

  pub struct EquipmentStatus {
    pub let key: String
    pub let enabled: Bool
    pub let level: UFix64

    init(
      _ key: String,
      enabled: Bool,
      level: UFix64
    ) {
      self.key = key
      self.enabled = enabled
      self.level = level
    }
  }
}

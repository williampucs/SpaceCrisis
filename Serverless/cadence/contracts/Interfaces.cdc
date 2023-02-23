import Helper from "./Helper.cdc"

pub contract Interfaces {

  pub resource interface ProfilePublic {
    pub var isAttached: Bool
    pub fun getSource(): String

    pub fun bindedPlatformInfo(): Helper.PlatformInfo
    pub fun getUserId(): String {
      return self.bindedPlatformInfo().identity.toString()
    }
  }

  pub resource interface ProfilePrivate {
    pub var isAttached: Bool
    pub fun getSource(): String

    access(account) fun setAttached() {
      self.isAttached = true
    }
  }

  pub resource interface GameServicePublic {
    pub fun getSource(): String

    access(account) fun initialize()
    access(account) fun createProfile(platform: String, uid: String): @{ProfilePublic, ProfilePrivate}
    access(account) fun borrowServiceAdmin(): auth &{GameServiceAdmin}
  }

  pub resource interface GameServiceAdmin {
    pub fun getSource(): String
  }
}

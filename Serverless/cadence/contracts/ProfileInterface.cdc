import MetadataViews from "./deps/MetadataViews.cdc"

pub contract ProfileInterface {

  pub resource interface ProfilePublic {

    pub fun getSource(): String
  }
}

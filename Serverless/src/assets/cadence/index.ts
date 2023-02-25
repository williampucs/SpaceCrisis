/**
 * transactions
 */
import claimProfile from "./transactions/claim-space-crisis-profile.cdc?raw";

/**
 * script
 */
import getProfileStatus from "./scripts/is-space-crisis-profile-attached.cdc?raw";

export default {
  transactions: {
    claimProfile,
  },
  scripts: {
    getProfileStatus,
  },
};

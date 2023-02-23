export * as flow from "./flow.mjs";
export { default as Signer } from "./signer.mjs";
export * as actions from "./actions";
export * as utils from "./utils";

/**
 * assert
 * @param anyToCheck
 * @param message
 * @returns
 */
export function assert(anyToCheck: boolean, message: string): boolean {
  if (!anyToCheck) {
    throw new Error(message);
  }
  return true;
}

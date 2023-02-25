import * as uuid from "uuid";

export default defineEventHandler((event) => {
  const config = useRuntimeConfig();

  const bytesA = uuid.parse(uuid.v1()) as Uint8Array;
  const bytesB = uuid.parse(uuid.v4()) as Uint8Array;

  // merged hex string with 32 bytes
  const nonce = [...bytesA]
    .concat([...bytesB])
    .map((v: number) => v.toString(16).padStart(2, "0"))
    .join("");
  // return account proof data
  return {
    appIdentifier: config.public.title,
    nonce,
    datetime: new Date(),
  };
});

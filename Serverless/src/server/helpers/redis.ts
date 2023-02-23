import { Redis } from "@upstash/redis";

const isRedisConfigEnabled = !!(
  process.env.UPSTASH_REDIS_REST_URL && process.env.UPSTASH_REDIS_REST_TOKEN
);

const networkKey = process.env.NUXT_PUBLIC_NETWORK ?? "testnet";
const dappKey = "FLOW_QUEST";

const redisPool: { [key: string]: Redis } = {};

export function getRedisInstance(key = "default"): Redis {
  let ins = redisPool[key];
  if (!ins) {
    const url = process.env.UPSTASH_REDIS_REST_URL;
    const token = process.env.UPSTASH_REDIS_REST_TOKEN;
    if (url && token) {
      redisPool[key] = ins = new Redis({ url, token });
    } else {
      throw new Error("Missing url and token");
    }
  }
  return ins;
}

export async function executeOrLoadFromRedis<T>(
  methodKey: string,
  methodPromise: Promise<T>
): Promise<T> {
  if (!isRedisConfigEnabled) {
    return await methodPromise;
  }

  const redis = getRedisInstance();
  const redisKey = `${dappKey}:SERVICE_CACHE:${networkKey}:KEY_VALUE:${methodKey}`;
  const cacheResult = await redis.get<string>(redisKey);

  let result: T;
  if (!cacheResult) {
    result = await methodPromise;
    await redis.set<string>(
      redisKey,
      typeof result === "string" ? result : JSON.stringify(result),
      { ex: 1800 } /* ex: half a hour */
    );
  } else {
    try {
      result = JSON.parse(cacheResult) as T;
    } catch (err) {
      result = cacheResult as T;
    }
  }
  return result;
}

export async function acquireKeyIndex(
  address: string,
  ttl?: number
): Promise<number> {
  const totalKeyAmt = parseInt(useRuntimeConfig().flowKeyAmount);
  if (!isRedisConfigEnabled) {
    return Math.floor(Math.random() * totalKeyAmt);
  }

  const redis = getRedisInstance();
  const redisTotalAmountKey = `${dappKey}:SERVICE_POOL:${networkKey}:ADDRESS:${address}:KEY_VALUE`;
  const redisKeyPool = `${dappKey}:SERVICE_POOL:${networkKey}:ADDRESS:${address}:SORTED_SET`;

  const now = Date.now();
  const timeout = now + (ttl ?? 1000 * 60);
  const pair = await redis.zpopmin<string>(redisKeyPool, 1);
  if (pair && pair.length === 2) {
    const [key, score] = pair;
    // set a timeout for key
    await redis.zadd(redisKeyPool, {
      member: key,
      score: timeout,
    });
    if (now - parseInt(score) >= 0) {
      // return key index
      return parseInt(key);
    }
  }
  // Need a new Key, check if reach max key?
  const currentKeyAmtStr = await redis.get<string>(redisTotalAmountKey);
  const currentKeyAmt = parseInt(currentKeyAmtStr ?? "0");
  if (totalKeyAmt > currentKeyAmt) {
    const p = redis.pipeline();
    p.incr(redisTotalAmountKey);
    p.zadd(redisKeyPool, {
      member: currentKeyAmt.toString(),
      score: timeout,
    });
    await p.exec();
    // return current max key index
    return currentKeyAmt;
  } else {
    throw new Error("Reach max key amount.");
  }
}

export async function releaseKeyIndex(address: string, keyIndex: number) {
  if (!isRedisConfigEnabled) return;

  const redis = getRedisInstance();
  const redisKeyPool = `${dappKey}:SERVICE_POOL:${networkKey}:ADDRESS:${address}:SORTED_SET`;

  // set a timeout for key
  await redis.zadd(redisKeyPool, {
    member: keyIndex.toString(),
    score: Date.now(),
  });
}

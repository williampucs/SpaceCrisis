<script setup lang="ts">
import { Icon } from '@iconify/vue';

const user = useCurrentUser()
const wallet = useWalletAccount();
const isNetworkCorrect = useNetworkCorrect();

interface Status {
  exists: boolean,
  attached: boolean,
}

const { data, refresh, pending } = useAsyncData<Status>(`user-${user.value?.platform}-${user.value?.uid}`, async () => {
  let ret: Status = { exists: false, attached: false }
  if (user.value) {
    const { $scripts } = useNuxtApp()
    return await $scripts.getProfileStatus(user.value.platform, user.value.uid)
  }
  return ret
}, {
  server: false,
  lazy: true
})

async function sendTransaction(): Promise<string> {
  if (!user.value) {
    throw new Error('Without User')
  };
  const { $transactions } = useNuxtApp()
  return $transactions.claimProfile(user.value.platform, user.value.uid)
}
</script>

<template>
  <div class="hero h-[100vh]">
    <div class="hero-content">
      <div v-if="!user">
        <h3>No scoped user</h3>
        <span>Please check the URL, <code class="text-green-600">platform</code> and <code class="text-green-600">uid</code> are <b>required</b> in the query.</span>
      </div>
      <div v-else class="flex flex-col gap-4 items-center justify-center">
        <div v-if="pending" :aria-busy="true"></div>
        <h2 v-else-if="!data?.exists">
          Profile doesn't exist
        </h2>
        <div v-else class="mb-5 grid grid-cols-2 gap-4 text-3xl font-semibold">
          <span class="place-self-center">UserID:</span>
          <span>{{ `${user.platform}-${user.uid}` }}</span>
          <template v-if="wallet?.addr">
            <span class="place-self-center">Wallet:</span>
            <span>{{ wallet?.addr }}</span>
            <template v-if="!isNetworkCorrect">
              <span></span><span class="text-red-600 font-semibold">(Wrong Network)</span>
            </template>
          </template>
        </div>
        <FlowConnectButton v-if="!wallet?.loggedIn" :huge="true" />
        <FlowSubmitTransaction
          v-else
          :method="sendTransaction"
          :disabled="pending || data?.attached"
          :huge-button="true"
          @reset="refresh()"
        >
          <div class="flex-center gap-2">
            <Icon icon="heroicons:cloud-arrow-down-solid" class="w-6 h-6" />
            <span>Claim Profile</span>
          </div>
          <template v-slot:disabled>
            <div class="flex-center gap-2">
              <Icon icon="heroicons:check-circle-solid" class="w-6 h-6" />
              <span>Claimed</span>
            </div>
          </template>
        </FlowSubmitTransaction>
      </div>
    </div>
  </div>
</template>

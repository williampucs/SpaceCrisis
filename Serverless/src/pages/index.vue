<script setup lang="ts">
import { Icon } from '@iconify/vue';

const user = useCurrentUser()
const wallet = useWalletAccount();

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
  <div>
    <div v-if="!user">
      No Linked User
    </div>
    <div v-else-if="!pending" class="flex flex-col gap-4">
      <div v-if="!data?.exists">
        Profile not exists
      </div>
      <template v-else>
        <div class="">
          {{ user }}
        </div>
        <FlowConnectButton v-if="!wallet?.loggedIn" />
        <FlowSubmitTransaction
          v-else
          :method="sendTransaction"
          :disabled="data?.attached"
          @sealed="refresh()"
        >
          Claim Profile
          <template v-slot:disabled>
            <div class="flex items-center justify-around">
              <Icon icon="heroicons:check-circle-solid" class="w-6 h-6" />
              <span>Claimed</span>
            </div>
          </template>
        </FlowSubmitTransaction>
      </template>
    </div>
  </div>
</template>

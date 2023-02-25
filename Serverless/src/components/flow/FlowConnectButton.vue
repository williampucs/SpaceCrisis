<script setup lang="ts">
import { Icon } from '@iconify/vue';

withDefaults(defineProps<{
  huge?: boolean
}>(), {
  huge: false
})

const current = useWalletAccount();
const isNetworkCorrect = useNetworkCorrect();

const emit = defineEmits<{
  (e: 'connected', address: string): void;
  (e: 'disconnected'): void;
}>();

onMounted(() => {
  const cfg = useRuntimeConfig()
  const { $fcl } = useNuxtApp();

  $fcl.currentUser.subscribe((user) => {
    current.value = user;
    if (user) {
      const accountProof = user.services?.find(one => one.type === "account-proof")
      if (accountProof?.uid.startsWith("lilico")) {
        isNetworkCorrect.value = accountProof?.network === cfg.public.network
      } else {
        isNetworkCorrect.value = true
      }
      console.log(`Flow User loggedIn: ${user.addr}, network: ${accountProof?.network}, correct: ${isNetworkCorrect.value}`);
      console.log(`Proof: ${JSON.stringify(accountProof?.data)}`)
      emit('connected', user.addr!)
    } else {
      emit('disconnected')
    }
  });
});

function login() {
  const { $fcl } = useNuxtApp();
  $fcl.authenticate();
}

</script>

<template>
<button :class="[{ 'huge': huge }]" @click="login">
  <div class="inline-flex items-center justify-around gap-2">
    <Icon icon="heroicons:user-20-solid" :class="[huge ? 'h-8 w-8' : 'h-4 w-4']" />
    <small>Connect<span class="hidden xl:inline"> Wallet</span></small>
  </div>
</button>
</template>

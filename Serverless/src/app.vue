<script setup lang="ts">
const route = useRoute();
const locale = useLocale();
const cfg = useRuntimeConfig();
const isNetworkCorrect = useNetworkCorrect();

useHead({
  titleTemplate: `%s - ${cfg.public.title}`,
});

// ----- Data -----
const description = ref(
  "An on-chain game profile management framework."
);

onMounted(() => {
  window.addEventListener("message", receiveMessage, false);
})

onUnmounted(() => {
  window.removeEventListener("message", receiveMessage, false)
})

function receiveMessage(event: any) {
  if (event.data?.type === 'LILICO:NETWORK' && typeof event.data?.network === 'string') {
    const cfg = useRuntimeConfig()
    const network = event.data?.network
    if (cfg.public.network !== network && isNetworkCorrect.value) {
      isNetworkCorrect.value = false
    } else if (cfg.public.network === network && !isNetworkCorrect.value) {
      isNetworkCorrect.value = true
    }
  }
}
</script>

<template>
<Html :lang="locale">
  <noscript>You need to enable JavaScript to run this app.</noscript>

  <HeadMeta :title="String(route.meta.title ?? 'Home')" :description="description" :url="route.fullPath" />

  <NuxtLayout>
    <NuxtPage />
  </NuxtLayout>
</Html>
</template>

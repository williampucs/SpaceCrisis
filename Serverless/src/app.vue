<script setup lang="ts">
const route = useRoute();
const locale = useLocale();
const appConfig = useAppConfig();

useHead({
  titleTemplate: `%s - ${appConfig.title}`,
});

// ----- Data -----
const description = ref(
  "An on-chain game profile management framework."
);
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

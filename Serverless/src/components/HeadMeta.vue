<script setup lang="ts">
withDefaults(
  defineProps<{
    title: string;
    description: string;
    url: string;
    author?: string;
  }>(),
  {
    author: "Anymous",
  }
);
const appConfig = useAppConfig();
const socialImageUrl = ref("https://i.imgur.com/r23Zhvu.png")
</script>

<template>
<Head>
  <Title>{{ title }}</Title>
  <!-- Primary Meta Tags -->
  <Meta name="title" :content="`${title} - ${appConfig.title}`" />
  <Meta name="author" :content="author" />
  <Meta name="description" :content="description" />

  <!-- Open Graph / Facebook -->
  <Meta property="og:type" content="website" />
  <Meta property="og:url" :content="url" />
  <Meta property="og:title" :content="`${title} - ${appConfig.title}`" />
  <Meta property="og:description" :content="description" />
  <Meta property="og:image" :content="socialImageUrl" />

  <!-- Twitter -->
  <Meta name="twitter:card" property="twitter:card" content="summary_large_image" />
  <Meta name="twitter:title" property="twitter:title" :content="`${title} - ${appConfig.title}`" />
  <Meta name="twitter:description" property="twitter:description" :content="description" />
  <Meta name="twitter:url" property="twitter:url" :content="url" />
  <Meta name="twitter:image" property="twitter:image" :content="socialImageUrl" />
  <meta name="twitter:image:alt" property="twitter:image:alt" :content="description" />

  <!--  Non-Essential, But Required for Analytics -->
  <Meta name="twitter:site" content="@william_pucs" />

  <!-- Other meta -->
  <slot />
</Head>
</template>

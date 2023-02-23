import inject from "@rollup/plugin-inject";
import { nodePolyfills } from "vite-plugin-node-polyfills";

// https://v3.nuxtjs.org/api/configuration/nuxt.config
export default defineNuxtConfig({
  // set source dir
  srcDir: "src/",
  // App Variables
  appConfig: {
    title: "Space Crisis",
  },
  // Environment Variables
  runtimeConfig: {
    // The private keys which are only available within server-side
    // NOTHING
    // Keys within public, will be also exposed to the client-side
    public: {
      flowServiceAddress: "",
      network: "",
      accessApi: "",
      walletDiscovery: "",
    },
  },
  // ts config
  typescript: {
    shim: false,
  },
  app: {
    head: {
      link: [
        // Favicons
        {
          rel: "apple-touch-icon",
          sizes: "180x180",
          href: "/apple-touch-icon.png",
        },
        {
          rel: "icon",
          type: "image/png",
          sizes: "32x32",
          href: "/favicon-32x32.png",
        },
        {
          rel: "icon",
          type: "image/png",
          sizes: "16x16",
          href: "/favicon-16x16.png",
        },
        {
          rel: "manifest",
          href: "/site.webmanifest",
        },
      ],
    },
  },
  // installed modules
  modules: [
    // Doc: https://github.com/nuxt-community/tailwindcss-module
    "@nuxtjs/tailwindcss",
  ],
  build: {
    transpile: [],
  },
  // vite configure
  vite: {
    // raw assets
    assetsInclude: ["**/*.cdc"],
    // plugins
    plugins: [
      nodePolyfills({
        // Whether to polyfill `node:` protocol imports.
        protocolImports: true,
      }),
    ],
    build: {
      rollupOptions: {
        plugins: [inject({ Buffer: ["buffer", "Buffer"] })],
      },
    },
    optimizeDeps: {
      esbuildOptions: {
        // Node.js global to browser globalThis
        define: {
          global: "globalThis",
        },
      },
    },
  },
  nitro: {
    preset: "vercel",
  },
});

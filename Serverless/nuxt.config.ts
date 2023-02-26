import fs from "fs";
import path from "path";
import inject from "@rollup/plugin-inject";
import { nodePolyfills } from "vite-plugin-node-polyfills";

const jsonStr = fs.readFileSync(path.join(process.cwd(), "flow.json"), "utf8");
const flowJson = JSON.parse(jsonStr);
const localContracts: string[] = [];
for (const key in flowJson.contracts) {
  if (typeof flowJson.contracts[key] === "string") {
    localContracts.push(key);
  }
}

// https://v3.nuxtjs.org/api/configuration/nuxt.config
export default defineNuxtConfig({
  // set source dir
  srcDir: "src/",
  // App Variables
  appConfig: {},
  // Environment Variables
  runtimeConfig: {
    // The private keys which are only available within server-side
    flowAdminAddress: "",
    flowKeyAmount: "100",
    flowPrivateKey: "",
    // Keys within public, will be also exposed to the client-side
    public: {
      title: "Space Crisis",
      network: "",
      accessApi: "",
      walletDiscovery: "",
      flowServiceAddress: "",
      localContracts: localContracts.join(","),
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
    routeRules: {
      "/api/**": {
        cors: true,
        headers: {
          "Content-Type": "application/json",
        },
      },
    },
  },
});

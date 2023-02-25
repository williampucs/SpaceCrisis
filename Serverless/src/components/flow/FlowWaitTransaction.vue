
<script setup lang="ts">
import type { TransactionReceipt } from "@onflow/fcl";

const props = withDefaults(defineProps<{
  txid: string;
  hidden?: boolean;
}>(), {
  hidden: false
});

const emit = defineEmits<{
  (e: "updated", tx: TransactionReceipt): void;
  (e: "sealed", tx: TransactionReceipt): void;
  (e: "error", message: string): void;
}>();

const txStatus = ref<TransactionReceipt | null>(null);

const txStatusString = computed(() => {
  const STATUS_MAP: { [key: number]: string } = {
    0: "SENT",
    1: "PENDING",
    2: "FINALIZED",
    3: "EXECUTED",
    4: "SEALED",
    5: "EXPIRED",
  };
  return (
    txStatus.value?.statusString ?? STATUS_MAP[txStatus.value?.status || 0]
  );
});

const progress = computed(() => {
  const status = txStatus.value?.status ?? 0;
  switch (status) {
    case 0:
    case 1:
    case 5:
      return undefined;
    case 2:
    case 3:
    case 4:
      return Math.min(100, (status - 1) * 33.34);
  }
});

const txidDisplay = computed(() => {
  const str = props.txid;
  return str.slice(0, 6) + "..." + str.slice(str.length - 6);
});

let unsub: any;

async function startSubscribe() {
  const { $fcl } = useNuxtApp();
  try {
    console.info(
      `%cTX[${props.txid}]: ${fvsTx(props.txid)}`,
      "color:purple;font-weight:bold;font-family:monospace;"
    );
    unsub = await $fcl.tx(props.txid).subscribe((tx) => {
      if (!tx.blockId || !tx.status) return;
      txStatus.value = tx;
      if ($fcl.tx.isSealed(tx)) {
        emit("sealed", tx);
        if (tx.errorMessage && tx.errorMessage.length > 0) {
          emit("error", tx.errorMessage)
        }
        unsub();
        unsub = null;
      } else {
        emit("updated", tx);
      }
    });
  } catch (err: any) {
    console.error(`TX[${props.txid}]: ${fvsTx(props.txid)}`, err);
    emit("error", err.message);
  }
}

function stopSubscribe() {
  if (typeof unsub === "function") {
    unsub();
  }
}

function fvsTx(txId: string) {
  // const config = useRuntimeConfig();
  // const env = config.public.network;
  return `https://f.dnz.dev/${txId}`;
}

onMounted(startSubscribe);
onBeforeUnmount(stopSubscribe);
</script>

<template>
  <div v-if="!hidden"
    class="absolute left-0 bottom-0 m-2 w-fit bg-native rounded-xl flex flex-col items-center justify-center">
    <div
      class="w-full px-3 py-2 bg-native rounded-lg text-center border-2 border-solid border-primary flex flex-col gap-2">
      <slot></slot>
      <div class="font-semibold text-lg flex items-center gap-2">
        <span class="">{{ txStatusString }}</span>
        <a :href="fvsTx(txid)" target="_blank" class="link-highlight">
          {{ txidDisplay }}
        </a>
      </div>
      <progress class="w-full" :value="progress" max="100"></progress>
    </div>
    <slot name="append"></slot>
  </div>
</template>

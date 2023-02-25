
<script setup lang="ts">
import type { TransactionReceipt } from "@onflow/fcl";

const isNetworkCorrect = useNetworkCorrect();

const props = withDefaults(
  defineProps<{
    method: () => Promise<string | null>;
    content?: string;
    action?: string;
    disabled?: boolean;
    halfButton?: boolean;
    hideButton?: boolean;
    hideTrx?: boolean;
  }>(),
  {
    content: "Submit",
    action: '',
    disabled: false,
    halfButton: false,
    hideButton: false,
    hideTrx: false,
  }
);

const emit = defineEmits<{
  (e: "sealed", tx: TransactionReceipt): void;
  (e: 'success'): void;
  (e: "error", message: string): void;
  (e: "reset"): void;
}>();

const txid = ref<string | null>(null);
const isLoading = ref(false);
const errorMessage = ref<string | null>(null);
const isSealed = ref<boolean | undefined>(undefined);

async function startTransaction() {
  if (!isNetworkCorrect.value || isLoading.value) return;

  isLoading.value = true;
  errorMessage.value = null;
  isSealed.value = false;
  try {
    txid.value = await props.method();
  } catch (err: any) {
    isSealed.value = true;
    console.error(err);
    const msg = String(err.reason ?? err.message ?? "rejected");
    errorMessage.value = msg.length > 60 ? msg.slice(0, 60) + "..." : msg;
    emit("error", errorMessage.value);
  }
  isLoading.value = false;
}

function onSealed(tx: TransactionReceipt) {
  isSealed.value = true;
  if (!tx.errorMessage) {
    emit("success")
  }
  emit("sealed", tx);
  // avoid no closed
  setTimeout(() => {
    if (txid.value) {
      resetComponent()
    }
  }, 3000);
}

function onError(msg: string) {
  errorMessage.value = msg
  emit("error", msg);
}

function resetComponent() {
  emit("reset")
  txid.value = null;
  errorMessage.value = null;
  isSealed.value = undefined;
}

// expose members
defineExpose({
  resetComponent: ref(resetComponent),
  startTransaction: ref(startTransaction),
  isLoading,
  isSealed
});
</script>

<template>
  <div class="flex flex-col gap-2 bg-native rounded-xl">
    <button v-if="disabled && !txid" :class="['mb-0', halfButton ? '!rounded-b-xl' : '!rounded-xl']"
      role="button"
      disabled>
      <slot name="disabled">
        Disabled
      </slot>
    </button>
    <template v-else-if="!hideButton && (!txid || !isSealed)">
      <button :class="['mb-0', halfButton ? '!rounded-b-xl' : '!rounded-xl']" role="button"
        :aria-busy="isLoading || isSealed === false" :disabled="!isNetworkCorrect || isLoading || isSealed === false"
        :aria-disabled="!isNetworkCorrect || isLoading || isSealed === false" @click="startTransaction">
        <slot>
          {{ content }}
        </slot>
      </button>
      <p v-if="errorMessage" class="w-full max-h-20 overflow-y-scroll bg-native px-4 mb-0 text-xs text-failure">
        {{ errorMessage }}
      </p>
      </template>
    <slot v-if="!hideButton && (txid && isSealed)" name="next">
      <button :class="['mx-0 mb-0 text-sm', halfButton ? '!rounded-b-xl' : 'rounded-xl']" role="button"
        @click.stop.prevent="resetComponent">
        Close
      </button>
    </slot>
    <Teleport to="body">
      <FlowWaitTransaction v-if="txid" :hidden="hideTrx" :txid="txid" @sealed="onSealed" @error="onError">
        <template v-if="action != ''">
          <h5 class="mb-0">{{ action }}</h5>
        </template>
        <template v-slot:append>
          <pre v-if="errorMessage" class="w-full max-h-20 overflow-y-scroll bg-native px-4 mb-0 text-xs text-failure">
            {{ errorMessage }}
          </pre>
        </template>
      </FlowWaitTransaction>
      </Teleport>
  </div>
</template>

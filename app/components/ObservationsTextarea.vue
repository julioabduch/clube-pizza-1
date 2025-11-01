<script setup lang="ts">
import { ref, computed } from 'vue'

const observations = defineModel<string>({ default: '' })

const maxLength = 200
const currentLength = computed(() => observations.value.length)
</script>

<template>
  <div id="observations-section" class="space-y-2">
    <div>
      <h3 class="text-base font-semibold text-highlighted mb-1">
        Observações
      </h3>
      <p class="text-sm text-muted">
        Adicione observações sobre seu pedido (opcional)
      </p>
    </div>

    <UTextarea
      v-model="observations"
      :maxlength="maxLength"
      placeholder="Ex: sem cebola, bem assada, borda recheada..."
      :rows="4"
      class="w-full"
    />

    <div class="flex justify-end">
      <span class="text-xs text-muted">
        {{ currentLength }}/{{ maxLength }} caracteres
      </span>
    </div>
  </div>
</template>

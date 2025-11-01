<script setup lang="ts">
defineProps<{
  label?: string
  variant?: 'primary' | 'secondary' | 'warning'
  disabled?: boolean
  loading?: boolean
  fullWidth?: boolean
}>()

const emit = defineEmits<{
  click: []
}>()
</script>

<template>
  <UButton
    id="action-button"
    :color="variant === 'secondary' ? 'error' : variant === 'warning' ? 'warning' : 'primary'"
    size="lg"
    :block="fullWidth"
    :disabled="disabled"
    :loading="loading"
    class="rounded-lg font-bold text-white text-base"
    @click="emit('click')"
  >
    <slot>{{ label }}</slot>
  </UButton>
</template>

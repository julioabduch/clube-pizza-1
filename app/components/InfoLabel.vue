<script setup lang="ts">
defineProps<{
  text?: string
  variant?: 'yellow' | 'white' | 'default'
}>()
</script>

<template>
  <div
    id="info-label"
    :class="[
      'rounded-full px-4 py-2 text-center text-sm font-medium',
      variant === 'yellow' 
        ? 'bg-yellow-400 text-gray-900' 
        : variant === 'white'
        ? 'bg-white border border-gray-200 text-default'
        : 'bg-orange-50 text-default border border-orange-200'
    ]"
  >
    <slot>{{ text }}</slot>
  </div>
</template>

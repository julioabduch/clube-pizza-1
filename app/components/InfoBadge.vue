<script setup lang="ts">
defineProps<{
  label?: string
  color?: 'yellow' | 'orange' | 'red'
}>()
</script>

<template>
  <UBadge
    id="info-badge"
    :color="color === 'yellow' ? 'warning' : 'primary'"
    variant="solid"
    size="xs"
    class="rounded-full px-2 py-1 text-xs font-semibold uppercase text-gray-900"
  >
    {{ label || 'Popular' }}
  </UBadge>
</template>

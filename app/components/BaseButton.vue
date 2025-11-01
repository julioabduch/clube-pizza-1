<template>
  <UButton
    :type="type"
    :disabled="disabled"
    :loading="loading"
    :color="variantColor"
    :variant="variantStyle"
    size="lg"
    block
  >
    <slot></slot>
  </UButton>
</template>

<script setup lang="ts">
const props = defineProps<{
  type?: 'button' | 'submit' | 'reset'
  variant?: 'primary' | 'secondary' | 'outline' | 'danger'
  disabled?: boolean
  loading?: boolean
}>()

const variantColor = computed(() => {
  const variant = props.variant || 'primary'
  if (variant === 'primary' || variant === 'outline') return 'primary' as const
  if (variant === 'secondary') return 'neutral' as const
  if (variant === 'danger') return 'error' as const
  return 'primary' as const
})

const variantStyle = computed(() => {
  return props.variant === 'outline' ? ('outline' as const) : ('solid' as const)
})
</script>

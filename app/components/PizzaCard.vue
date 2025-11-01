<script setup lang="ts">
const props = defineProps<{
  name: string
  description: string
  isPremium?: boolean
  isSelected?: boolean
}>()

const emit = defineEmits<{
  select: []
}>()
</script>

<template>
  <UCard
    :id="`pizza-card-${name.toLowerCase().replace(/\s+/g, '-')}`"
    :ui="{
      root: isSelected ? 'ring-2 ring-primary cursor-pointer transition-all hover:shadow-md' : 'cursor-pointer transition-all hover:shadow-md'
    }"
    class="p-4"
    @click="emit('select')"
  >
    <div class="space-y-2">
      <div class="flex items-start justify-between gap-2">
        <h3 class="text-base font-semibold text-highlighted">
          {{ name }}
        </h3>
        <UBadge
          v-if="isPremium"
          color="primary"
          variant="solid"
          size="xs"
          class="text-white font-bold text-sm"
        >
          Premium
        </UBadge>
      </div>
      <p class="text-sm text-muted">
        {{ description }}
      </p>
    </div>
  </UCard>
</template>

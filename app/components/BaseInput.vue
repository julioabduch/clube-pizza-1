<template>
  <UFormField :label="label" :error="error" :required="required">
    <UInput
      :id="id"
      :type="type"
      :model-value="modelValue"
      :placeholder="placeholder"
      :required="required"
      :disabled="disabled"
      size="lg"
      @update:model-value="$emit('update:modelValue', $event)"
    />
  </UFormField>
</template>

<script setup lang="ts">
defineProps<{
  modelValue: string
  type?: string
  label?: string
  placeholder?: string
  required?: boolean
  disabled?: boolean
  error?: string
  id?: string
}>()

defineEmits<{
  'update:modelValue': [value: string]
}>()
</script>

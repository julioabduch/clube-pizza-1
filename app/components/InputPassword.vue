<template>
  <UFormField :label="label" :error="error" :required="required">
    <UInput
      :id="id"
      :type="showPassword ? 'text' : 'password'"
      :model-value="modelValue"
      :placeholder="placeholder"
      :required="required"
      :disabled="disabled"
      size="lg"
      @update:model-value="$emit('update:modelValue', $event)"
    >
      <template #trailing>
        <UButton
          :icon="showPassword ? 'i-heroicons-eye-slash' : 'i-heroicons-eye'"
          color="neutral"
          variant="link"
          :padded="false"
          @click="togglePassword"
        />
      </template>
    </UInput>
  </UFormField>
</template>

<script setup lang="ts">
const showPassword = ref(false)

defineProps<{
  modelValue: string
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

const togglePassword = () => {
  showPassword.value = !showPassword.value
}
</script>

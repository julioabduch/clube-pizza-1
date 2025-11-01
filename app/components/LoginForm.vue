<template>
  <UForm :state="state" @submit="handleSubmit" class="space-y-6">
    <UAlert
      v-if="errorMessage"
      color="error"
      variant="soft"
      :title="errorMessage"
      :close-button="{ icon: 'i-heroicons-x-mark', color: 'error', variant: 'link' }"
      @close="errorMessage = ''"
    />

    <BaseInput
      v-model="state.email"
      type="email"
      label="Email"
      placeholder="seu@email.com"
      required
      id="email"
    />

    <InputPassword
      v-model="state.password"
      label="Senha"
      placeholder="••••••••"
      required
      id="password"
    />

    <BaseButton type="submit" :loading="loading">
      Entrar
    </BaseButton>
  </UForm>
</template>

<script setup lang="ts">
const state = reactive({
  email: '',
  password: ''
})

const loading = ref(false)
const errorMessage = ref('')

const { login } = useAuth()

const handleSubmit = async () => {
  loading.value = true
  errorMessage.value = ''

  try {
    await login(state.email, state.password)
    await navigateTo('/')
  } catch (error: any) {
    errorMessage.value = error.message || 'Erro ao fazer login. Verifique suas credenciais.'
  } finally {
    loading.value = false
  }
}
</script>

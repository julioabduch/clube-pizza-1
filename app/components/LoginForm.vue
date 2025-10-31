<template>
  <form @submit.prevent="handleSubmit" class="space-y-6">
    <div v-if="errorMessage" class="bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded-lg text-sm">
      {{ errorMessage }}
    </div>

    <BaseInput
      v-model="email"
      type="email"
      label="Email"
      placeholder="seu@email.com"
      required
      id="email"
    />

    <InputPassword
      v-model="password"
      label="Senha"
      placeholder="••••••••"
      required
      id="password"
    />

    <BaseButton type="submit" :loading="loading">
      Entrar
    </BaseButton>
  </form>
</template>

<script setup lang="ts">
const email = ref('')
const password = ref('')
const loading = ref(false)
const errorMessage = ref('')

const { login } = useAuth()

const handleSubmit = async () => {
  loading.value = true
  errorMessage.value = ''

  try {
    await login(email.value, password.value)
    await navigateTo('/')
  } catch (error: any) {
    errorMessage.value = error.message || 'Erro ao fazer login. Verifique suas credenciais.'
  } finally {
    loading.value = false
  }
}
</script>

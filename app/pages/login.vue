<template>
  <div class="min-h-screen bg-gradient-to-br from-red-600 to-orange-600 flex items-center justify-center p-4">
    <UCard class="w-full max-w-md">
      <template #header>
        <div class="text-center">
          <UIcon name="i-heroicons-cake" class="w-16 h-16 text-orange-600 mx-auto mb-4" />
          <h1 class="text-3xl font-bold text-gray-900 mb-2">
            Bem-vindo
          </h1>
          <p class="text-gray-600">
            Entre com suas credenciais para continuar
          </p>
        </div>
      </template>

      <LoginForm />

      <template #footer>
        <div class="space-y-4">
          <div class="text-center">
            <ULink to="#" class="text-sm text-red-700 hover:text-red-800">
              Esqueceu sua senha?
            </ULink>
          </div>

          <div class="text-center text-sm text-gray-600">
            Não tem uma conta?
            <ULink to="#" class="text-orange-700 hover:text-orange-800 font-semibold">
              Cadastre-se
            </ULink>
          </div>
        </div>
      </template>
    </UCard>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: false
})
</script>

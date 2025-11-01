<template>
  <div class="min-h-screen bg-gradient-to-br from-orange-50 via-orange-100 to-orange-200 flex items-center justify-center p-4">
    <UCard class="w-full max-w-md">
      <template #header>
        <div class="text-center">
          <UIcon name="i-heroicons-cake" class="w-16 h-16 text-primary mx-auto mb-4" />
          <h1 class="text-3xl font-bold text-highlighted mb-2">
            Bem-vindo
          </h1>
          <p class="text-muted">
            Entre com suas credenciais para continuar
          </p>
        </div>
      </template>

      <LoginForm />

      <template #footer>
        <div class="space-y-4">
          <div class="text-center">
            <ULink to="#" class="text-sm text-primary hover:text-primary/80">
              Esqueceu sua senha?
            </ULink>
          </div>

          <div class="text-center text-sm text-muted">
            Não tem uma conta?
            <ULink to="#" class="text-primary hover:text-primary/80 font-semibold">
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

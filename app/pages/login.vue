<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center p-4">
    <div class="w-full max-w-md">
      <div class="bg-white rounded-2xl shadow-2xl p-8 md:p-10">
        <div class="text-center mb-8">
          <h1 class="text-3xl font-bold text-gray-800 mb-2">
            Bem-vindo de volta
          </h1>
          <p class="text-gray-600">
            Entre com suas credenciais para continuar
          </p>
        </div>

        <LoginForm />

        <div class="mt-6 text-center">
          <a href="#" class="text-sm text-blue-600 hover:text-blue-700 hover:underline">
            Esqueceu sua senha?
          </a>
        </div>

        <div class="mt-8 text-center text-sm text-gray-600">
          Não tem uma conta?
          <a href="#" class="text-blue-600 hover:text-blue-700 font-semibold hover:underline">
            Cadastre-se
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Lógica será implementada depois
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center p-4">
    <div class="max-w-2xl w-full">
      <div class="bg-white rounded-2xl shadow-2xl p-8 md:p-12">
        <h1 class="text-4xl md:text-5xl font-bold text-gray-800 mb-4">
          Bem-vindo ao Nuxt + Tailwind! 🎨
        </h1>
        
        <p class="text-lg text-gray-600 mb-8">
          Este é um template com Nuxt 4, Supabase e Tailwind CSS totalmente configurado.
        </p>

        <div class="grid md:grid-cols-3 gap-4 mb-8">
          <div class="bg-blue-100 rounded-lg p-4 text-center">
            <div class="text-3xl mb-2">⚡</div>
            <h3 class="font-semibold text-blue-800">Nuxt 4</h3>
          </div>
          
          <div class="bg-green-100 rounded-lg p-4 text-center">
            <div class="text-3xl mb-2">🎨</div>
            <h3 class="font-semibold text-green-800">Tailwind CSS</h3>
          </div>
          
          <div class="bg-purple-100 rounded-lg p-4 text-center">
            <div class="text-3xl mb-2">🔥</div>
            <h3 class="font-semibold text-purple-800">Supabase</h3>
          </div>
        </div>

        <button class="w-full bg-gradient-to-r from-blue-500 to-purple-600 text-white font-semibold py-3 px-6 rounded-lg hover:from-blue-600 hover:to-purple-700 transform hover:scale-105 transition duration-200 shadow-lg">
          Começar Agora
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
// Adicione sua lógica aqui
</script>

<script setup lang="ts">
// Mock dos dados do pedido (virá do estado/backend depois)
const orderData = {
  code: 'CP0123',
  flavors: ['4 Queijos com Bacon', 'Pizza Curitiba'],
  date: '28 de outubro de 2025 às 14:34',
  status: 'Aguardando confirmação da pizzaria'
}

const handleWhatsApp = () => {
  // Aqui virá a lógica de abrir WhatsApp
  console.log('Abrir WhatsApp')
}

const handleGoHome = () => {
  navigateTo('/dashboard')
}
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-orange-50 via-orange-100 to-orange-200 flex items-center justify-center p-4">
    <div class="max-w-2xl w-full">
      <UCard class="shadow-2xl">
        <!-- Ícone de Sucesso -->
        <div class="text-center mb-6">
          <div class="inline-flex items-center justify-center w-20 h-20 bg-green-100 rounded-full mb-4">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="2"
              stroke="currentColor"
              class="w-12 h-12 text-green-600"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
              />
            </svg>
          </div>

          <h1 class="text-3xl font-bold text-green-600 mb-2">
            Pedido Confirmado!
          </h1>
          <p class="text-base text-default">
            Seu pedido foi registrado com sucesso 🍕
          </p>
        </div>

        <!-- Detalhes do Pedido -->
        <div class="bg-orange-50 rounded-lg p-6 space-y-4 mb-6">
          <!-- Código do Pedido -->
          <div>
            <p class="text-sm text-muted mb-1">Código do Pedido</p>
            <p class="text-2xl font-bold text-secondary">
              {{ orderData.code }}
            </p>
          </div>

          <!-- Sabores Escolhidos -->
          <div>
            <p class="text-sm text-muted mb-2">Sabores Escolhidos</p>
            <div class="flex flex-wrap gap-2">
              <UBadge
                v-for="(flavor, index) in orderData.flavors"
                :key="index"
                color="error"
                variant="solid"
                size="md"
                class="px-3 py-1 text-white font-bold text-sm"
              >
                {{ flavor }}
              </UBadge>
            </div>
          </div>

          <!-- Data do Pedido -->
          <div>
            <p class="text-sm text-muted mb-1">Data do Pedido</p>
            <p class="text-base text-default font-medium">
              {{ orderData.date }}
            </p>
          </div>

          <!-- Status -->
          <div>
            <p class="text-sm text-muted mb-1">Status</p>
            <p class="text-base text-default font-medium">
              {{ orderData.status }}
            </p>
          </div>
        </div>

        <!-- Mensagem adicional -->
        <div class="bg-blue-50 rounded-lg p-4 mb-6">
          <p class="text-sm text-default text-center">
            Deseja adicionar bebidas ou pizzas fora do plano?
          </p>
        </div>

        <!-- Botões de Ação -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <!-- Botão WhatsApp -->
          <UButton
            color="success"
            size="lg"
            block
            class="text-white font-bold text-base"
            @click="handleWhatsApp"
          >
            <template #leading>
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="currentColor"
                viewBox="0 0 24 24"
                class="w-5 h-5"
              >
                <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413Z"/>
              </svg>
            </template>
            Ir para o WhatsApp
          </UButton>

          <!-- Botão Voltar -->
          <UButton
            variant="outline"
            color="neutral"
            size="lg"
            block
            class="font-bold text-base"
            @click="handleGoHome"
          >
            <template #leading>
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="2"
                stroke="currentColor"
                class="w-5 h-5"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25"
                />
              </svg>
            </template>
            Voltar ao Início
          </UButton>
        </div>

        <!-- Nota informativa -->
        <div class="mt-6 bg-purple-50 rounded-lg p-4">
          <p class="text-xs text-center text-muted">
            A pizzaria receberá sua confirmação e entrará em contato em breve. Você pode acompanhar o status do seu pedido no painel inicial.
          </p>
        </div>
      </UCard>
    </div>
  </div>
</template>

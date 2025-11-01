<script setup lang="ts">
import { ref } from 'vue'

// Mock dos sabores disponíveis (depois virão do backend)
const classicFlavors = [
  {
    id: 1,
    name: 'Calabresa',
    description: 'Mussarela e calabresa fatiada',
    isPremium: false
  },
  {
    id: 2,
    name: 'Frango com Catupiry',
    description: 'Mussarela, frango e catupiry',
    isPremium: false
  },
  {
    id: 3,
    name: 'Napolitana',
    description: 'Mussarela, tomate e parmesão',
    isPremium: false
  },
  {
    id: 4,
    name: 'Portuguesa',
    description: 'Mussarela, presunto, cebola, azeitona e ovos',
    isPremium: false
  }
]

const premiumFlavors = [
  {
    id: 5,
    name: '4 Queijos com Bacon',
    description: 'Mussarela, provolone, parmesão, catupiry e bacon',
    isPremium: true
  },
  {
    id: 6,
    name: 'Frango Especial',
    description: 'Mussarela, batata palha, frango, creme de leite e bacon',
    isPremium: true
  },
  {
    id: 7,
    name: 'Champignon',
    description: 'Mussarela e champignon',
    isPremium: true
  },
  {
    id: 8,
    name: 'Pizza Curitiba',
    description: 'Mussarela, bacon, presunto, calabresa, milho, cebola e tomate',
    isPremium: true
  }
]

// Estado do pedido
const selectedFlavors = ref<number[]>([])
const observations = ref('')
const userPlan = ref('premium') // 'classic' ou 'premium'

// Sabores disponíveis baseado no plano
const availableFlavors = computed(() => {
  if (userPlan.value === 'premium') {
    return [...classicFlavors, ...premiumFlavors]
  }
  return classicFlavors
})

// Verificar se sabor está selecionado
const isFlavorSelected = (flavorId: number) => {
  return selectedFlavors.value.includes(flavorId)
}

// Selecionar/desselecionar sabor
const toggleFlavor = (flavorId: number) => {
  const index = selectedFlavors.value.indexOf(flavorId)
  
  if (index > -1) {
    // Remover sabor
    selectedFlavors.value.splice(index, 1)
  } else {
    // Adicionar sabor (máximo 2)
    if (selectedFlavors.value.length < 2) {
      selectedFlavors.value.push(flavorId)
    }
  }
}

// Resumo do pedido
const orderSummary = computed(() => {
  if (selectedFlavors.value.length === 0) {
    return 'Nenhum sabor selecionado'
  }
  
  const flavorNames = selectedFlavors.value.map(id => {
    const flavor = availableFlavors.value.find(f => f.id === id)
    return flavor?.name
  })
  
  return flavorNames.join(' + ')
})

// Confirmar pedido
const handleConfirmOrder = () => {
  // Aqui virá a lógica de salvar o pedido no backend
  console.log('Pedido confirmado:', {
    flavors: selectedFlavors.value,
    observations: observations.value
  })
  
  // Navegar para página de confirmação
  navigateTo('/pedidoconfirmado')
}

// Voltar
const handleBack = () => {
  navigateTo('/dashboard')
}
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-orange-50 via-orange-100 to-orange-200">
    <div class="container mx-auto px-4 py-8 max-w-4xl">
      <!-- Botão Voltar -->
      <div class="mb-6">
        <BackButton label="Voltar" @click="handleBack" />
      </div>

      <!-- Cabeçalho -->
      <div class="text-center mb-8 space-y-2">
        <h1 class="text-4xl font-bold text-secondary">
          Monte sua Pizza
        </h1>
        <UBadge color="error" variant="solid" size="md" class="px-3 py-1 text-white font-bold text-base">
          Plano Premium
        </UBadge>
        <p class="text-base text-muted">
          Escolha até 2 sabores para sua pizza gigante
        </p>
      </div>

      <!-- Sabores Disponíveis -->
      <div class="mb-8">
        <h2 class="text-xl font-semibold text-highlighted mb-4">
          Sabores Disponíveis
        </h2>
        <p class="text-sm text-muted mb-4">
          Selecione 1 ou 2 sabores para sua pizza desta semana
        </p>

        <!-- Grid de Sabores -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <PizzaCard
            v-for="flavor in availableFlavors"
            :key="flavor.id"
            :name="flavor.name"
            :description="flavor.description"
            :is-premium="flavor.isPremium"
            :is-selected="isFlavorSelected(flavor.id)"
            @select="toggleFlavor(flavor.id)"
          />
        </div>
      </div>

      <!-- Observações -->
      <div class="mb-8">
        <ObservationsTextarea v-model="observations" />
      </div>

      <!-- Resumo do Pedido -->
      <div class="mb-8">
        <UCard class="p-6">
          <h3 class="text-lg font-semibold text-highlighted mb-2">
            Resumo do Pedido:
          </h3>
          <p class="text-base text-default">
            {{ orderSummary }}
          </p>
        </UCard>
      </div>

      <!-- Botão Confirmar -->
      <UCard class="p-6">
        <ConfirmButton
          :disabled="selectedFlavors.length === 0"
          @confirm="handleConfirmOrder"
        />
      </UCard>
    </div>
  </div>
</template>

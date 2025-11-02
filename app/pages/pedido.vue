<script setup lang="ts">
import type { PizzaFlavorDTO } from '../../shared/types'

// Composables
const { 
  summary,
  planName,
  canOrderThisWeek,
  currentOrderCode,
  fetch: fetchSummary
} = useSubscriptionSummary()

const { 
  flavors,
  loading: loadingFlavors,
  error: errorFlavors,
  fetchForCurrentUser
} = usePizzaFlavors()

const { 
  createOrder,
  loading: loadingOrder,
  error: errorOrder
} = useOrders()

// Estado do pedido
const selectedFlavors = ref<string[]>([]) // UUIDs dos sabores
const observations = ref('')
const showSuccessMessage = ref(false)

// Buscar dados ao montar
onMounted(async () => {
  await fetchSummary()
  
  // Se já fez pedido esta semana, redireciona
  if (currentOrderCode.value) {
    navigateTo('/pedidoconfirmado')
    return
  }
  
  // Buscar sabores do plano do usuário
  await fetchForCurrentUser()
})

// Verificar se sabor está selecionado
const isFlavorSelected = (flavorId: string) => {
  return selectedFlavors.value.includes(flavorId)
}

// Selecionar/desselecionar sabor
const toggleFlavor = (flavorId: string) => {
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
    const flavor = flavors.value.find((f: PizzaFlavorDTO) => f.id === id)
    return flavor?.name
  })
  
  return flavorNames.join(' + ')
})

// Confirmar pedido
const handleConfirmOrder = async () => {
  if (selectedFlavors.value.length === 0) {
    return
  }

  const flavor1 = selectedFlavors.value[0]
  const flavor2 = selectedFlavors.value[1] || null

  if (!flavor1) {
    return
  }

  // Criar pedido via RPC (idempotente)
  const order = await createOrder(
    flavor1,
    flavor2,
    null, // address_id (por enquanto null, adicionar depois)
    observations.value || null
  )

  if (order) {
    // Sucesso! Redirecionar para página de confirmação
    navigateTo('/pedidoconfirmado')
  }
  // Se houver erro, a mensagem já está em errorOrder
}

// Voltar
const handleBack = () => {
  navigateTo('/dashboard')
}

// Tipo do plano para o badge
const planBadgeColor = computed(() => {
  if (!summary.value) return 'error'
  return summary.value.plan === 'premium' ? 'error' : 'primary'
})

const planBadgeLabel = computed(() => {
  return planName.value || 'Carregando...'
})
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-orange-50 via-orange-100 to-orange-200">
    <div class="container mx-auto px-4 py-8 max-w-4xl">
      <!-- Botão Voltar -->
      <div class="mb-6">
        <BackButton label="Voltar" @click="handleBack" />
      </div>

      <!-- Erro ao carregar dados -->
      <UAlert
        v-if="errorFlavors || errorOrder"
        color="error"
        variant="soft"
        :title="errorFlavors || errorOrder || 'Erro'"
        class="mb-6"
      />

      <!-- Loading -->
      <div v-if="loadingFlavors" class="text-center py-12">
        <p class="text-muted">Carregando sabores disponíveis...</p>
      </div>

      <!-- Sem sabores disponíveis -->
      <div v-else-if="!loadingFlavors && flavors.length === 0" class="text-center py-12">
        <UCard>
          <div class="p-8">
            <h2 class="text-2xl font-bold text-highlighted mb-4">
              Nenhum sabor disponível
            </h2>
            <p class="text-muted mb-6">
              Não encontramos sabores para o seu plano. Entre em contato com o suporte.
            </p>
            <UButton
              color="primary"
              @click="handleBack"
            >
              Voltar ao Dashboard
            </UButton>
          </div>
        </UCard>
      </div>

      <!-- Formulário de pedido -->
      <template v-else>
        <!-- Cabeçalho -->
        <div class="text-center mb-8 space-y-2">
          <h1 class="text-4xl font-bold text-secondary">
            Monte sua Pizza
          </h1>
          <UBadge 
            :color="planBadgeColor" 
            variant="solid" 
            size="md" 
            class="px-3 py-1 text-white font-bold text-base"
          >
            {{ planBadgeLabel }}
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
              v-for="flavor in flavors"
              :key="flavor.id"
              :name="flavor.name"
              :description="flavor.description"
              :is-premium="flavor.plan === 'premium'"
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
            :disabled="selectedFlavors.length === 0 || loadingOrder"
            :loading="loadingOrder"
            @confirm="handleConfirmOrder"
          />
        </UCard>
      </template>
    </div>
  </div>
</template>

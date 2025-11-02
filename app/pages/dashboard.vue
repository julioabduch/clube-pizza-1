<script setup lang="ts">
const user = useSupabaseUser()

// Composables do dashboard
const { 
  summary,
  loading: loadingSummary,
  error: errorSummary,
  hasActiveSubscription,
  planName,
  cycleName,
  weekProgress,
  canOrderThisWeek,
  currentOrderCode,
  fetch: fetchSummary
} = useSubscriptionSummary()

// Buscar dados ao montar
onMounted(async () => {
  await fetchSummary()
})

// Handlers
const handleMakeOrder = () => {
  if (!canOrderThisWeek.value) {
    return
  }
  navigateTo('/pedido')
}

const handleLogout = async () => {
  const supabase = useSupabaseClient()
  await supabase.auth.signOut()
  navigateTo('/login')
}

// Status da semana para o card (apenas 'available' | 'ordered' | 'delivered')
const weekStatus = computed<'available' | 'ordered' | 'delivered'>(() => {
  if (!hasActiveSubscription.value) return 'available'
  if (currentOrderCode.value) return 'ordered'
  return 'available'
})

const weekStatusText = computed(() => {
  if (loadingSummary.value) return 'Carregando...'
  if (!hasActiveSubscription.value) return 'Sem assinatura ativa'
  if (currentOrderCode.value) return `Pedido realizado: ${currentOrderCode.value}`
  return 'Pizza disponível'
})

const badgeLabel = computed(() => {
  if (!hasActiveSubscription.value) return 'Sem plano'
  return planName.value || 'Carregando...'
})

const planDescription = computed(() => {
  if (!hasActiveSubscription.value) return 'Assine um plano para começar'
  return `1 pizza gigante por semana • ${cycleName.value}`
})
</script>


<template>
  <div class="min-h-screen bg-gradient-to-br from-orange-50 via-orange-100 to-orange-200">
    <div class="container mx-auto px-4 py-8 max-w-4xl">
      <!-- Cabeçalho com saudação e botão sair -->
      <div class="flex items-center justify-between mb-8">
        <div>
          <h1 class="text-3xl font-bold text-secondary mb-1">
            Olá, {{ user?.email?.split('@')[0] || 'usuário' }}!
          </h1>
          <p class="text-base text-muted">
            Bem-vindo ao Clube da Pizza
          </p>
        </div>
        
        <UButton
          variant="ghost"
          color="neutral"
          @click="handleLogout"
        >
          <template #trailing>
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
                d="M15.75 9V5.25A2.25 2.25 0 0 0 13.5 3h-6a2.25 2.25 0 0 0-2.25 2.25v13.5A2.25 2.25 0 0 0 7.5 21h6a2.25 2.25 0 0 0 2.25-2.25V15M12 9l-3 3m0 0 3 3m-3-3h12.75"
              />
            </svg>
          </template>
          Sair
        </UButton>
      </div>

      <!-- Erro ao carregar -->
      <UAlert
        v-if="errorSummary"
        color="error"
        variant="soft"
        :title="errorSummary"
        class="mb-6"
      />

      <!-- Loading -->
      <div v-if="loadingSummary" class="text-center py-12">
        <p class="text-muted">Carregando seus dados...</p>
      </div>

      <!-- Sem assinatura -->
      <div v-else-if="!hasActiveSubscription" class="text-center py-12">
        <UCard>
          <div class="p-8">
            <h2 class="text-2xl font-bold text-highlighted mb-4">
              Você ainda não tem uma assinatura ativa
            </h2>
            <p class="text-muted mb-6">
              Escolha um plano para começar a receber pizzas deliciosas toda semana!
            </p>
            <UButton
              color="primary"
              size="lg"
              @click="navigateTo('/planos')"
            >
              Ver Planos Disponíveis
            </UButton>
          </div>
        </UCard>
      </div>

      <!-- Dashboard com assinatura ativa -->
      <template v-else>
        <!-- Grid de Cards -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
          <!-- Card do Plano -->
          <UserPlanCard
            :badge-label="badgeLabel"
            :description="planDescription"
          >
            <template v-if="summary" #footer>
              <p class="text-sm text-muted">
                Semanas usadas: {{ weekProgress }}
              </p>
            </template>
          </UserPlanCard>

          <!-- Card de Status -->
          <WeekStatusCard
            :status="weekStatus"
            :status-text="weekStatusText"
          />
        </div>

        <!-- Card com Botão de Ação -->
        <UCard class="p-8">
          <ActionButton
            :label="canOrderThisWeek ? 'Fazer Pedido da Semana' : 'Pedido já realizado'"
            variant="secondary"
            full-width
            :disabled="!canOrderThisWeek"
            @click="handleMakeOrder"
          >
            <template #leading>
              <span class="text-2xl">🍕</span>
            </template>
            {{ canOrderThisWeek ? 'Fazer Pedido da Semana' : 'Pedido já realizado' }}
          </ActionButton>
        </UCard>
      </template>
    </div>
  </div>
</template>

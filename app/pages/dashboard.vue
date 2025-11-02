<script setup lang="ts">
const supabase = useSupabaseClient()
const user = useSupabaseUser()
const { subscription, loading: loadingSubscription, error: subscriptionError, fetchUserSubscription } = useSubscription()
const { weekStatus, weekStatusText, loading: loadingPedidos, fetchCurrentWeekOrder } = usePedidos()

// Aguarda o usuário estar disponível e então busca os dados
watch(user, async (newUser) => {
  if (newUser) {
    // Busca o user.id correto do Supabase auth
    const { data: { user: authUser } } = await supabase.auth.getUser()
    const userId = authUser?.id
    
    if (userId) {
      await Promise.all([
        fetchUserSubscription(userId),
        fetchCurrentWeekOrder()
      ])
    }
  }
}, { immediate: true })

const handleMakeOrder = () => {
  navigateTo('/pedido')
}

const handleLogout = async () => {
  const supabase = useSupabaseClient()
  await supabase.auth.signOut()
  navigateTo('/login')
}
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

      <!-- Grid de Cards -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        <!-- Card do Plano -->
        <UserPlanCard
          v-if="!loadingSubscription && subscription"
          :badge-label="subscription.plan?.name || 'Plano Premium'"
          :description="subscription.plan?.description || '1 pizza gigante por semana'"
        />
        
        <!-- Estado de carregamento -->
        <UCard v-else-if="loadingSubscription" id="user-plan-card" class="p-6">
          <div class="space-y-4">
            <USkeleton class="h-6 w-32" />
            <USkeleton class="h-8 w-40" />
            <USkeleton class="h-4 w-full" />
          </div>
        </UCard>
        
        <!-- Sem plano ativo -->
        <UCard v-else id="user-plan-card" class="p-6">
          <div class="space-y-4">
            <div class="flex items-center gap-2">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="2"
                stroke="currentColor"
                class="w-6 h-6 text-muted"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M12 8.25v-1.5m0 1.5c-1.355 0-2.697.056-4.024.166C6.845 8.51 6 9.473 6 10.608v2.513m6-4.871c1.355 0 2.697.056 4.024.166C17.155 8.51 18 9.473 18 10.608v2.513M15 8.25v-1.5m-6 1.5v-1.5m12 9.75-1.5.75a3.354 3.354 0 0 1-3 0 3.354 3.354 0 0 0-3 0 3.354 3.354 0 0 1-3 0 3.354 3.354 0 0 0-3 0 3.354 3.354 0 0 1-3 0L3 16.5m15-3.379a48.474 48.474 0 0 0-6-.371c-2.032 0-4.034.126-6 .371m12 0c.39.049.777.102 1.163.16 1.07.16 1.837 1.094 1.837 2.175v5.169c0 .621-.504 1.125-1.125 1.125H4.125A1.125 1.125 0 0 1 3 20.625v-5.17c0-1.08.768-2.014 1.837-2.174A47.78 47.78 0 0 1 6 13.12M12.265 3.11a.375.375 0 1 1-.53 0L12 2.845l.265.265Zm-3 0a.375.375 0 1 1-.53 0L9 2.845l.265.265Zm6 0a.375.375 0 1 1-.53 0L15 2.845l.265.265Z"
                />
              </svg>
              <h2 class="text-lg font-semibold text-highlighted">
                Sem Plano Ativo
              </h2>
            </div>
            <p class="text-sm text-muted">
              Você ainda não possui um plano ativo. Escolha um plano para começar!
            </p>
            <UButton
              color="primary"
              variant="solid"
              @click="navigateTo('/planos')"
            >
              Ver Planos
            </UButton>
          </div>
        </UCard>

        <!-- Card de Status -->
        <WeekStatusCard
          v-if="!loadingPedidos"
          :status="weekStatus"
          :status-text="weekStatusText"
        />
        
        <!-- Estado de carregamento do status -->
        <UCard v-else id="week-status-card" class="p-6">
          <div class="space-y-4">
            <USkeleton class="h-6 w-48" />
            <USkeleton class="h-6 w-32" />
          </div>
        </UCard>
      </div>

      <!-- Card com Botão de Ação -->
      <UCard class="p-8">
        <ActionButton
          label="Fazer Pedido da Semana"
          variant="secondary"
          full-width
          @click="handleMakeOrder"
        >
          <template #leading>
            <span class="text-2xl">🍕</span>
          </template>
          Fazer Pedido da Semana
        </ActionButton>
      </UCard>
    </div>
  </div>
</template>

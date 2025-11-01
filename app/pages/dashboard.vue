<script setup lang="ts">
const user = useSupabaseUser()

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
          badge-label="Plano Premium"
          description="1 pizza gigante por semana"
        />

        <!-- Card de Status -->
        <WeekStatusCard
          status="available"
          status-text="Pizza disponível"
        />
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

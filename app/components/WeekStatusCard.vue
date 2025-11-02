<script setup lang="ts">
defineProps<{
  status?: 'available' | 'ordered' | 'delivered'
  statusText?: string
}>()

const statusConfig = {
  available: {
    icon: 'check-circle',
    color: 'text-green-600',
    bgColor: 'bg-green-50',
    text: 'Pizza disponível'
  },
  ordered: {
    icon: 'clock',
    color: 'text-orange-600',
    bgColor: 'bg-orange-50',
    text: 'Pedido realizado'
  },
  delivered: {
    icon: 'check-badge',
    color: 'text-blue-600',
    bgColor: 'bg-blue-50',
    text: 'Pizza entregue'
  }
}
</script>

<template>
  <UCard id="week-status-card" class="p-6">
    <div class="space-y-4">
      <!-- Título com ícone -->
      <div class="flex items-center gap-2">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="2"
          stroke="currentColor"
          class="w-6 h-6 text-secondary"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5"
          />
        </svg>
        <h2 class="text-lg font-semibold text-highlighted">
          Status desta Semana
        </h2>
      </div>

      <!-- Status com ícone -->
      <div class="flex items-center gap-3">
        <!-- Ícone de Check (disponível) -->
        <svg
          v-if="(status || 'available') === 'available'"
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="2"
          stroke="currentColor"
          class="w-6 h-6 text-green-600"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
          />
        </svg>

        <!-- Ícone de Clock (pedido realizado) -->
        <svg
          v-else-if="status === 'ordered'"
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="2"
          stroke="currentColor"
          class="w-6 h-6 text-orange-600"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
          />
        </svg>

        <!-- Ícone de Entregue (delivered) -->
        <svg
          v-else
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="2"
          stroke="currentColor"
          class="w-6 h-6 text-blue-600"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M9 12.75 11.25 15 15 9.75m-3-7.036A11.959 11.959 0 0 1 3.598 6 11.99 11.99 0 0 0 3 9.749c0 5.592 3.824 10.29 9 11.623 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.571-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285Z"
          />
        </svg>

        <span 
          :class="[
            'text-base font-medium',
            status === 'available' || !status ? 'text-green-600' : 
            status === 'ordered' ? 'text-orange-600' : 
            'text-blue-600'
          ]"
        >
          {{ statusText || statusConfig[status || 'available'].text }}
        </span>
      </div>
    </div>
  </UCard>
</template>

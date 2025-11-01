<script setup lang="ts">
import type { Component } from 'vue'

defineProps<{
  planName: string
  description: string
  price: string
  priceLabel?: string
  icon?: Component
  iconBgColor?: string
  flavorsTitle?: string
  flavors?: string[]
  infoLabels?: string[]
  actionButtonLabel?: string
  actionButtonVariant?: 'primary' | 'secondary' | 'warning'
  isPopular?: boolean
  borderColor?: string
}>()

const emit = defineEmits<{
  selectFlavors: []
  subscribe: []
}>()
</script>

<template>
  <UCard
    id="plan-card"
    :ui="{
      root: borderColor ? `border-2 ${borderColor}` : ''
    }"
    class="relative"
  >
    <!-- Badge Popular -->
    <div v-if="isPopular" class="absolute top-4 right-4">
      <InfoBadge color="yellow" label="POPULAR" />
    </div>

    <div class="flex flex-col items-center text-center space-y-6 p-4">
      <!-- Ícone -->
      <div 
        :class="[
          'w-16 h-16 rounded-full flex items-center justify-center',
          iconBgColor || 'bg-red-100'
        ]"
      >
        <component :is="icon" v-if="icon" class="w-8 h-8" />
        <!-- Emoji de Pizza -->
        <span v-else class="text-4xl">🍕</span>
      </div>

      <!-- Título e Descrição -->
      <div class="space-y-2">
        <h2 class="text-2xl font-bold text-highlighted">
          {{ planName }}
        </h2>
        <p class="text-sm text-muted">
          {{ description }}
        </p>
      </div>

      <!-- Preço -->
      <div class="space-y-1">
        <div class="text-4xl font-bold text-secondary">
          {{ price }}
        </div>
        <p class="text-sm text-muted">
          {{ priceLabel || 'por mês' }}
        </p>
      </div>

      <!-- Sabores Disponíveis -->
      <div v-if="flavors && flavors.length > 0" class="w-full text-left space-y-3">
        <h3 class="text-base font-semibold text-highlighted">
          {{ flavorsTitle || 'Sabores disponíveis:' }}
        </h3>
        <ul class="space-y-2">
          <li
            v-for="(flavor, index) in flavors"
            :key="index"
            class="flex items-start gap-2 text-sm text-default"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="2.5"
              stroke="currentColor"
              class="w-5 h-5 text-secondary flex-shrink-0 mt-0.5"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="m4.5 12.75 6 6 9-13.5"
              />
            </svg>
            <span>{{ flavor }}</span>
          </li>
        </ul>
      </div>

      <!-- Info Labels (Escolha até 2 sabores, etc) -->
      <div v-if="infoLabels && infoLabels.length > 0" class="w-full space-y-3">
        <InfoLabel
          v-for="(label, index) in infoLabels"
          :key="index"
          variant="yellow"
          :text="label"
        />
      </div>

      <!-- Botão de Ação -->
      <div class="w-full">
        <ActionButton
          :variant="actionButtonVariant || 'secondary'"
          :label="actionButtonLabel || 'Assinar Plano'"
          full-width
          @click="emit('subscribe')"
        />
      </div>
    </div>
  </UCard>
</template>

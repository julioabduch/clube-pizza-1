import type { SubscriptionPlan } from './enums'

// Tabela: pizza_flavors
// Catálogo de sabores disponíveis por plano

export interface PizzaFlavorDTO {
  id: string // UUID
  name: string
  description: string
  plan: SubscriptionPlan // 'classico' | 'premium'
  active: boolean
  created_at: string
}

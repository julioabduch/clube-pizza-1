import type { SubscriptionPlan, BillingCycle } from './enums'

// Tabela: subscriptions
// Assinatura do usuário (1 por usuário, sem troca de plano)

export interface SubscriptionDTO {
  id: string // UUID
  user_id: string // UUID - referência auth.users(id)
  plan: SubscriptionPlan // 'classico' | 'premium'
  cycle: BillingCycle // 'monthly' | 'quarterly'
  weeks_total: number // 4 (mensal) ou 13 (trimestral)
  weekly_quota: number // 1 pizza/semana (padrão)
  active: boolean
  started_at: string
  expires_at: string | null
  created_at: string
}

export interface CreateSubscriptionDTO {
  plan: SubscriptionPlan
  cycle: BillingCycle
  weeks_total?: number // calculado automaticamente se não fornecido
  weekly_quota?: number // padrão: 1
}

// NOTA: Não há UpdateSubscriptionDTO pois plano/ciclo/quota
// são bloqueados após criação (trigger prevent_plan_change)

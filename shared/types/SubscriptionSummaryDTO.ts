import type { SubscriptionPlan, BillingCycle } from './enums'

// VIEW: v_subscription_summary
// Resumo completo da assinatura para o Dashboard
// ⚠️ IMPORTANTE: Use esta view (v_subscription_summary) no app - filtra por auth.uid()
// ⚠️ NÃO USE v_subscription_summary_admin no app - é apenas para administração

export interface SubscriptionSummaryDTO {
  subscription_id: string // UUID
  plan: SubscriptionPlan // 'classico' | 'premium'
  cycle: BillingCycle // 'monthly' | 'quarterly'
  weeks_used: number // quantas semanas já usou
  weeks_total: number // total de semanas do ciclo (4 ou 13)
  week_start: string // date - início da semana atual (segunda)
  week_end: string // date - fim da semana atual (domingo)
  current_week_has_order: boolean // já fez pedido nesta semana?
  order_code: string | null // código do pedido da semana (se existir)
}

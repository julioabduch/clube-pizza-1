export interface SubscriptionDTO {
  id: number
  user_id: string
  plan_id: number | null
  start_date: string
  end_date: string | null
  status: 'active' | 'paused' | 'canceled'
  auto_renew: boolean
  last_payment_at: string | null
  created_at: string
  plan?: PlanDTO
}

export interface PlanDTO {
  id: number
  name: string
  description: string
  price: number
  pizzas_per_week: number
  created_at: string
}

// Enums que espelham os tipos PostgreSQL do banco de dados

export type SubscriptionPlan = 'classico' | 'premium'

export type OrderStatus = 'pending' | 'preparing' | 'delivered' | 'cancelled'

export type BillingCycle = 'monthly' | 'quarterly'

import type { OrderStatus } from './enums'

// Tabela: orders
// Pedidos semanais (até 2 sabores, 1 por semana)

export interface OrderDTO {
  id: string // UUID
  user_id: string // UUID - referência auth.users(id)
  subscription_id: string // UUID - referência subscriptions(id)
  order_code: string // código único (ex: CP1234)
  flavor_1: string // UUID - referência pizza_flavors(id)
  flavor_2: string | null // UUID - referência pizza_flavors(id) (opcional)
  address_id: string | null // UUID - referência addresses(id)
  observations: string | null // ex: "sem cebola"
  status: OrderStatus // 'pending' | 'preparing' | 'delivered' | 'cancelled'
  week_start: string // date - sempre segunda-feira
  week_end: string // date - sempre domingo
  created_at: string
  delivered_at: string | null
}

// DTO para criar pedido via RPC api_place_order
export interface CreateOrderDTO {
  p_flavor_1: string // UUID do sabor 1
  p_flavor_2?: string | null // UUID do sabor 2 (opcional)
  p_address_id?: string | null // UUID do endereço
  p_observations?: string | null // observações
}

// Response da RPC api_place_order retorna OrderDTO completo

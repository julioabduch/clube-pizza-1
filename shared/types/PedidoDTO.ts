export interface PedidoDTO {
  id: number
  user_id: string | null
  subscription_id: number | null
  order_code: string
  order_date: string
  week_number: number | null
  week_start_date: string | null
  notes: string | null
  total_value: number
  sent: boolean
  sent_at: string | null
  validado: boolean
  validado_em: string | null
  expires_at: string | null
  created_at: string
}

export interface CreatePedidoDTO {
  subscription_id: number
  notes?: string
  total_value?: number
}

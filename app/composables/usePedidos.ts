import type { PedidoDTO, CreatePedidoDTO } from '../../shared/types/PedidoDTO'

export const usePedidos = () => {
  const supabase = useSupabaseClient<any>()
  const user = useSupabaseUser()

  const currentWeekOrder = useState<PedidoDTO | null>('current-week-order', () => null)
  const loading = useState<boolean>('pedidos-loading', () => false)
  const error = useState<string | null>('pedidos-error', () => null)

  /**
   * Calcula o número da semana do ano
   */
  const getWeekNumber = (date: Date): number => {
    const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()))
    const dayNum = d.getUTCDay() || 7
    d.setUTCDate(d.getUTCDate() + 4 - dayNum)
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1))
    return Math.ceil((((d.getTime() - yearStart.getTime()) / 86400000) + 1) / 7)
  }

  /**
   * Calcula a data de início da semana (segunda-feira)
   */
  const getWeekStartDate = (date: Date): string => {
    const d = new Date(date)
    const day = d.getDay()
    const diff = d.getDate() - day + (day === 0 ? -6 : 1) // Ajusta para segunda-feira
    d.setDate(diff)
    const isoString = d.toISOString().split('T')[0]
    return isoString || ''
  }

  /**
   * Busca o pedido da semana atual do usuário
   */
  const fetchCurrentWeekOrder = async () => {
    if (!user.value) {
      error.value = 'Usuário não autenticado'
      return null
    }

    loading.value = true
    error.value = null

    try {
      const today = new Date()
      const weekNumber = getWeekNumber(today)
      const weekStartDate = getWeekStartDate(today)

      const { data, error: fetchError } = await supabase
        .from('pedidos')
        .select('*')
        .eq('user_id', user.value.id)
        .eq('week_number', weekNumber)
        .gte('week_start_date', weekStartDate)
        .order('created_at', { ascending: false })
        .limit(1)
        .maybeSingle()

      if (fetchError) {
        throw fetchError
      }

      currentWeekOrder.value = data as PedidoDTO | null
      return data as PedidoDTO | null
    } catch (err: unknown) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao buscar pedido da semana'
      error.value = errorMessage
      console.error('Erro ao buscar pedido da semana:', err)
      return null
    } finally {
      loading.value = false
    }
  }

  /**
   * Cria um novo pedido
   */
  const createOrder = async (orderData: CreatePedidoDTO) => {
    if (!user.value) {
      error.value = 'Usuário não autenticado'
      return null
    }

    loading.value = true
    error.value = null

    try {
      // Gera código único do pedido
      const orderCode = `ORD-${Date.now()}-${Math.random().toString(36).substr(2, 9).toUpperCase()}`

      const { data, error: createError } = await supabase
        .from('pedidos')
        .insert({
          user_id: user.value.id,
          subscription_id: orderData.subscription_id,
          order_code: orderCode,
          notes: orderData.notes || null,
          total_value: orderData.total_value || 0,
          sent: false,
          validado: false,
        })
        .select()
        .single()

      if (createError) {
        throw createError
      }

      currentWeekOrder.value = data as PedidoDTO
      return data as PedidoDTO
    } catch (err: unknown) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao criar pedido'
      error.value = errorMessage
      console.error('Erro ao criar pedido:', err)
      return null
    } finally {
      loading.value = false
    }
  }

  /**
   * Marca pedido como enviado
   */
  const markOrderAsSent = async (orderId: number) => {
    loading.value = true
    error.value = null

    try {
      const { error: updateError } = await supabase
        .from('pedidos')
        .update({
          sent: true,
          sent_at: new Date().toISOString(),
        })
        .eq('id', orderId)

      if (updateError) {
        throw updateError
      }

      // Atualiza o estado local
      if (currentWeekOrder.value && currentWeekOrder.value.id === orderId) {
        currentWeekOrder.value.sent = true
        currentWeekOrder.value.sent_at = new Date().toISOString()
      }

      return true
    } catch (err: unknown) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao marcar pedido como enviado'
      error.value = errorMessage
      console.error('Erro ao marcar pedido como enviado:', err)
      return false
    } finally {
      loading.value = false
    }
  }

  /**
   * Valida um pedido (admin)
   */
  const validateOrder = async (orderId: number) => {
    loading.value = true
    error.value = null

    try {
      const { error: updateError } = await supabase
        .from('pedidos')
        .update({
          validado: true,
          validado_em: new Date().toISOString(),
        })
        .eq('id', orderId)

      if (updateError) {
        throw updateError
      }

      return true
    } catch (err: unknown) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao validar pedido'
      error.value = errorMessage
      console.error('Erro ao validar pedido:', err)
      return false
    } finally {
      loading.value = false
    }
  }

  /**
   * Verifica se o usuário já fez pedido na semana atual
   */
  const hasOrderedThisWeek = computed(() => {
    return currentWeekOrder.value !== null
  })

  /**
   * Verifica se o pedido já foi enviado/entregue
   */
  const isOrderSent = computed(() => {
    return currentWeekOrder.value?.sent === true
  })

  /**
   * Status da semana para exibição
   */
  const weekStatus = computed<'available' | 'ordered' | 'delivered'>(() => {
    if (!currentWeekOrder.value) {
      return 'available'
    }
    if (currentWeekOrder.value.sent) {
      return 'delivered'
    }
    return 'ordered'
  })

  /**
   * Texto do status da semana
   */
  const weekStatusText = computed(() => {
    switch (weekStatus.value) {
      case 'available':
        return 'Pizza disponível'
      case 'ordered':
        return 'Pedido realizado'
      case 'delivered':
        return 'Pizza entregue'
      default:
        return 'Status desconhecido'
    }
  })

  return {
    currentWeekOrder,
    loading,
    error,
    hasOrderedThisWeek,
    isOrderSent,
    weekStatus,
    weekStatusText,
    fetchCurrentWeekOrder,
    createOrder,
    markOrderAsSent,
    validateOrder,
  }
}

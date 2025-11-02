import type { OrderDTO, CreateOrderDTO } from '../../shared/types'

/**
 * Composable para gerenciar pedidos (orders)
 * 
 * Usa a RPC api_place_order() que é IDEMPOTENTE - se clicar 2x, só cria 1 pedido
 * 
 * @example
 * const { createOrder, loading, error } = useOrders()
 * const order = await createOrder(flavor1Id, flavor2Id, observations)
 */
export const useOrders = () => {
  const supabase = useSupabaseClient()
  
  const loading = ref(false)
  const error = ref<string | null>(null)
  const currentOrder = ref<OrderDTO | null>(null)

  /**
   * Cria um pedido usando a RPC api_place_order (idempotente)
   * 
   * Validações feitas pelo backend:
   * - Usuário tem assinatura ativa
   * - Sabores pertencem ao plano do usuário
   * - Ainda não pediu nesta semana (ou retorna o pedido existente)
   * - Não excedeu limite de semanas (4 ou 13)
   * 
   * @param flavor1Id - UUID do primeiro sabor (obrigatório)
   * @param flavor2Id - UUID do segundo sabor (opcional)
   * @param addressId - UUID do endereço de entrega (opcional)
   * @param observations - Observações do pedido (ex: "sem cebola")
   * @returns OrderDTO ou null em caso de erro
   */
  const createOrder = async (
    flavor1Id: string,
    flavor2Id?: string | null,
    addressId?: string | null,
    observations?: string | null
  ): Promise<OrderDTO | null> => {
    loading.value = true
    error.value = null
    currentOrder.value = null

    try {
      // Validar que tem pelo menos 1 sabor
      if (!flavor1Id) {
        error.value = 'Selecione pelo menos um sabor'
        return null
      }

      // Log dos parâmetros para debug
      console.log('🍕 Criando pedido:', {
        p_flavor_1: flavor1Id,
        p_flavor_2: flavor2Id || null,
        p_address_id: addressId || null,
        p_observations: observations || null
      })

      // Chamar RPC idempotente
      const { data, error: supabaseError } = await supabase.rpc('api_place_order', {
        p_flavor_1: flavor1Id,
        p_flavor_2: flavor2Id || null,
        p_address_id: addressId || null,
        p_observations: observations || null
      } as any)

      if (supabaseError) {
        // Erros possíveis:
        // - "Plano inválido ou limite de semanas atingido/fora da validade"
        // - "Já existe pedido nesta semana para esta assinatura"
        // - "Sabor não pertence ao plano da assinatura"
        // - "Sabor inválido"
        console.error('❌ Erro da RPC api_place_order:', supabaseError)
        throw supabaseError
      }

      console.log('✅ Pedido criado com sucesso:', data)
      currentOrder.value = data as OrderDTO
      return data as OrderDTO
    } catch (err: any) {
      console.error('Erro ao criar pedido:', err)
      error.value = err.message || 'Erro ao criar pedido. Tente novamente.'
      currentOrder.value = null
      return null
    } finally {
      loading.value = false
    }
  }

  /**
   * Lista pedidos do usuário atual
   * @param limit - número máximo de pedidos (padrão: 10)
   */
  const fetchUserOrders = async (limit: number = 10) => {
    loading.value = true
    error.value = null

    try {
      const { data: { user } } = await supabase.auth.getUser()
      
      if (!user?.id) {
        error.value = 'Usuário não autenticado'
        return []
      }

      const { data, error: supabaseError } = await supabase
        .from('orders')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })
        .limit(limit)

      if (supabaseError) {
        throw supabaseError
      }

      return (data as OrderDTO[]) || []
    } catch (err: any) {
      console.error('Erro ao buscar pedidos:', err)
      error.value = err.message || 'Erro ao carregar histórico'
      return []
    } finally {
      loading.value = false
    }
  }

  /**
   * Busca um pedido específico por código
   * @param orderCode - código do pedido (ex: "CP1234")
   */
  const fetchByCode = async (orderCode: string) => {
    loading.value = true
    error.value = null

    try {
      const { data: { user } } = await supabase.auth.getUser()
      
      if (!user?.id) {
        error.value = 'Usuário não autenticado'
        return null
      }

      const { data, error: supabaseError } = await supabase
        .from('orders')
        .select('*')
        .eq('user_id', user.id)
        .eq('order_code', orderCode)
        .single()

      if (supabaseError) {
        if (supabaseError.code === 'PGRST116') {
          error.value = 'Pedido não encontrado'
        } else {
          throw supabaseError
        }
        return null
      }

      return data as OrderDTO
    } catch (err: any) {
      console.error('Erro ao buscar pedido:', err)
      error.value = err.message || 'Erro ao buscar pedido'
      return null
    } finally {
      loading.value = false
    }
  }

  /**
   * Cancela um pedido pendente
   * @param orderId - UUID do pedido
   */
  const cancelOrder = async (orderId: string) => {
    loading.value = true
    error.value = null

    try {
      const { data: { user } } = await supabase.auth.getUser()
      
      if (!user?.id) {
        error.value = 'Usuário não autenticado'
        return false
      }

      // Apenas pedidos 'pending' podem ser cancelados
      const { error: supabaseError } = await (supabase
        .from('orders') as any)
        .update({ status: 'cancelled' })
        .eq('id', orderId)
        .eq('user_id', user.id)
        .eq('status', 'pending')

      if (supabaseError) {
        throw supabaseError
      }

      return true
    } catch (err: any) {
      console.error('Erro ao cancelar pedido:', err)
      error.value = err.message || 'Erro ao cancelar pedido'
      return false
    } finally {
      loading.value = false
    }
  }

  return {
    // State
    loading: readonly(loading),
    error: readonly(error),
    currentOrder: readonly(currentOrder),
    
    // Actions
    createOrder,
    fetchUserOrders,
    fetchByCode,
    cancelOrder
  }
}

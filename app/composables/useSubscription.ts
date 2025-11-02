import type { SubscriptionDTO } from '~/shared/types/SubscriptionDTO'

export const useSubscription = () => {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()

  const subscription = useState<SubscriptionDTO | null>('user-subscription', () => null)
  const loading = useState<boolean>('subscription-loading', () => false)
  const error = useState<string | null>('subscription-error', () => null)

  /**
   * Busca a assinatura ativa do usuário logado
   */
  const fetchUserSubscription = async (userId?: string) => {
    const currentUserId = userId || user.value?.id
    
    if (!currentUserId) {
      error.value = 'Usuário não autenticado'
      return null
    }

    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('subscriptions')
        .select(`
          *,
          plan:plans(*)
        `)
        .eq('user_id', currentUserId)
        .eq('status', 'active')
        .order('created_at', { ascending: false })
        .limit(1)
        .single()

      if (fetchError) {
        // Se não encontrar assinatura, não é erro crítico
        if (fetchError.code === 'PGRST116') {
          subscription.value = null
          return null
        }
        throw fetchError
      }

      subscription.value = data as SubscriptionDTO
      return data as SubscriptionDTO
    } catch (err: unknown) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao buscar assinatura'
      error.value = errorMessage
      console.error('Erro ao buscar assinatura:', err)
      return null
    } finally {
      loading.value = false
    }
  }

  /**
   * Cria uma nova assinatura para o usuário
   */
  const createSubscription = async (planId: number) => {
    if (!user.value) {
      error.value = 'Usuário não autenticado'
      return null
    }

    loading.value = true
    error.value = null

    try {
      const { data, error: createError } = await supabase
        .from('subscriptions')
        .insert({
          user_id: user.value.id,
          plan_id: planId,
          status: 'active',
          auto_renew: true,
        })
        .select(`
          *,
          plan:plans(*)
        `)
        .single()

      if (createError) {
        throw createError
      }

      subscription.value = data as SubscriptionDTO
      return data as SubscriptionDTO
    } catch (err: unknown) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao criar assinatura'
      error.value = errorMessage
      console.error('Erro ao criar assinatura:', err)
      return null
    } finally {
      loading.value = false
    }
  }

  /**
   * Cancela a assinatura do usuário
   */
  const cancelSubscription = async () => {
    if (!subscription.value) {
      error.value = 'Nenhuma assinatura ativa encontrada'
      return false
    }

    loading.value = true
    error.value = null

    try {
      const { error: updateError } = await supabase
        .from('subscriptions')
        .update({
          status: 'canceled',
          auto_renew: false,
        })
        .eq('id', subscription.value.id)

      if (updateError) {
        throw updateError
      }

      subscription.value = null
      return true
    } catch (err: unknown) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao cancelar assinatura'
      error.value = errorMessage
      console.error('Erro ao cancelar assinatura:', err)
      return false
    } finally {
      loading.value = false
    }
  }

  /**
   * Pausa a assinatura do usuário
   */
  const pauseSubscription = async () => {
    if (!subscription.value) {
      error.value = 'Nenhuma assinatura ativa encontrada'
      return false
    }

    loading.value = true
    error.value = null

    try {
      const { error: updateError } = await supabase
        .from('subscriptions')
        .update({ status: 'paused' })
        .eq('id', subscription.value.id)

      if (updateError) {
        throw updateError
      }

      if (subscription.value) {
        subscription.value.status = 'paused'
      }
      return true
    } catch (err: unknown) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao pausar assinatura'
      error.value = errorMessage
      console.error('Erro ao pausar assinatura:', err)
      return false
    } finally {
      loading.value = false
    }
  }

  /**
   * Reativa uma assinatura pausada
   */
  const resumeSubscription = async () => {
    if (!subscription.value) {
      error.value = 'Nenhuma assinatura encontrada'
      return false
    }

    loading.value = true
    error.value = null

    try {
      const { error: updateError } = await supabase
        .from('subscriptions')
        .update({ status: 'active' })
        .eq('id', subscription.value.id)

      if (updateError) {
        throw updateError
      }

      if (subscription.value) {
        subscription.value.status = 'active'
      }
      return true
    } catch (err: unknown) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao reativar assinatura'
      error.value = errorMessage
      console.error('Erro ao reativar assinatura:', err)
      return false
    } finally {
      loading.value = false
    }
  }

  return {
    subscription,
    loading,
    error,
    fetchUserSubscription,
    createSubscription,
    cancelSubscription,
    pauseSubscription,
    resumeSubscription,
  }
}

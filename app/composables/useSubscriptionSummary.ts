import type { SubscriptionSummaryDTO } from '../../shared/types'

/**
 * Composable para obter o resumo completo da assinatura (VIEW v_subscription_summary)
 * 
 * ⚠️ IMPORTANTE: Este composable usa v_subscription_summary que filtra por auth.uid()
 * ⚠️ NÃO USE v_subscription_summary_admin - é apenas para administração no dashboard Supabase
 * 
 * Retorna tudo que o dashboard precisa:
 * - Plano atual, ciclo, semanas usadas/totais
 * - Semana atual (seg→dom em SP)
 * - Se já tem pedido na semana + código
 * 
 * @example
 * const { summary, loading, error, refresh } = useSubscriptionSummary()
 */
export const useSubscriptionSummary = () => {
  const supabase = useSupabaseClient()
  
  const summary = ref<SubscriptionSummaryDTO | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  /**
   * Busca o resumo da assinatura do usuário atual
   * A VIEW v_subscription_summary já filtra pelo auth.uid() via RLS
   */
  const fetchSummary = async () => {
    loading.value = true
    error.value = null

    try {
      // Verificar se usuário está autenticado
      const { data: { user } } = await supabase.auth.getUser()
      
      if (!user?.id) {
        error.value = 'Usuário não autenticado'
        summary.value = null
        return
      }

      // Buscar resumo da VIEW (já vem tudo calculado)
      const { data, error: supabaseError } = await supabase
        .from('v_subscription_summary')
        .select('*')
        .single()

      if (supabaseError) {
        // Se não encontrar assinatura, não é erro - usuário pode não ter plano ainda
        if (supabaseError.code === 'PGRST116') {
          summary.value = null
          error.value = null
        } else {
          throw supabaseError
        }
        return
      }

      summary.value = data as SubscriptionSummaryDTO
    } catch (err: any) {
      console.error('Erro ao buscar resumo da assinatura:', err)
      error.value = err.message || 'Erro ao carregar dados da assinatura'
      summary.value = null
    } finally {
      loading.value = false
    }
  }

  // Computed helpers para facilitar uso no template
  const hasActiveSubscription = computed(() => !!summary.value)
  
  const planName = computed(() => {
    if (!summary.value) return null
    return summary.value.plan === 'classico' ? 'Plano Clássico' : 'Plano Premium'
  })

  const cycleName = computed(() => {
    if (!summary.value) return null
    return summary.value.cycle === 'monthly' ? 'Mensal' : 'Trimestral'
  })

  const weekProgress = computed(() => {
    if (!summary.value) return '0/0'
    return `${summary.value.weeks_used}/${summary.value.weeks_total}`
  })

  const canOrderThisWeek = computed(() => {
    if (!summary.value) return false
    return !summary.value.current_week_has_order
  })

  const currentOrderCode = computed(() => {
    if (!summary.value) return null
    return summary.value.order_code
  })

  // Auto-fetch ao montar (pode ser desabilitado passando { immediate: false })
  const autoFetch = async () => {
    await fetchSummary()
  }

  return {
    // State
    summary: readonly(summary),
    loading: readonly(loading),
    error: readonly(error),
    
    // Computed helpers
    hasActiveSubscription,
    planName,
    cycleName,
    weekProgress,
    canOrderThisWeek,
    currentOrderCode,
    
    // Actions
    refresh: fetchSummary,
    fetch: autoFetch
  }
}

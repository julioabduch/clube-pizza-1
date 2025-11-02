import type { PizzaFlavorDTO, SubscriptionPlan } from '../../shared/types'

/**
 * Composable para listar sabores de pizza disponíveis
 * 
 * Filtra automaticamente pelo plano do usuário (classico ou premium)
 * Retorna apenas sabores ativos
 * 
 * @example
 * const { flavors, loading, fetchByPlan } = usePizzaFlavors()
 * await fetchByPlan('premium')
 */
export const usePizzaFlavors = () => {
  const supabase = useSupabaseClient()
  
  const flavors = ref<PizzaFlavorDTO[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  /**
   * Busca sabores disponíveis para um plano específico
   * @param plan - 'classico' ou 'premium'
   * 
   * REGRA: 
   * - Plano Clássico → apenas sabores clássicos
   * - Plano Premium → sabores clássicos + premium (todos)
   */
  const fetchByPlan = async (plan: SubscriptionPlan) => {
    loading.value = true
    error.value = null

    try {
      let query = supabase
        .from('pizza_flavors')
        .select('*')
        .eq('active', true)
        .order('name', { ascending: true })

      // Se for plano clássico, filtra apenas clássicos
      // Se for premium, retorna TODOS (não filtra por plan)
      if (plan === 'classico') {
        query = query.eq('plan', 'classico')
      }
      // Premium não filtra - retorna todos os sabores

      const { data, error: supabaseError } = await query

      if (supabaseError) {
        throw supabaseError
      }

      flavors.value = (data as PizzaFlavorDTO[]) || []
    } catch (err: any) {
      console.error('Erro ao buscar sabores:', err)
      error.value = err.message || 'Erro ao carregar sabores'
      flavors.value = []
    } finally {
      loading.value = false
    }
  }

  /**
   * Busca sabores usando o plano da assinatura ativa do usuário
   * Integra com useSubscriptionSummary
   */
  const fetchForCurrentUser = async () => {
    loading.value = true
    error.value = null

    try {
      // Buscar plano do usuário via VIEW
      const { data: summary, error: summaryError } = await supabase
        .from('v_subscription_summary')
        .select('plan')
        .single()

      if (summaryError) {
        if (summaryError.code === 'PGRST116') {
          error.value = 'Você não possui assinatura ativa'
        } else {
          throw summaryError
        }
        flavors.value = []
        loading.value = false
        return
      }

      const plan = (summary as any).plan as SubscriptionPlan
      await fetchByPlan(plan)
    } catch (err: any) {
      console.error('Erro ao buscar sabores do usuário:', err)
      error.value = err.message || 'Erro ao carregar sabores'
      flavors.value = []
      loading.value = false
    }
  }

  /**
   * Busca um sabor específico por ID
   */
  const fetchById = async (flavorId: string) => {
    try {
      const { data, error: supabaseError } = await supabase
        .from('pizza_flavors')
        .select('*')
        .eq('id', flavorId)
        .single()

      if (supabaseError) {
        throw supabaseError
      }

      return data as PizzaFlavorDTO
    } catch (err: any) {
      console.error('Erro ao buscar sabor:', err)
      return null
    }
  }

  // Computed helpers
  const hasClassicFlavors = computed(() => 
    flavors.value.some((f: PizzaFlavorDTO) => f.plan === 'classico')
  )

  const hasPremiumFlavors = computed(() => 
    flavors.value.some((f: PizzaFlavorDTO) => f.plan === 'premium')
  )

  const flavorCount = computed(() => flavors.value.length)

  return {
    // State
    flavors: readonly(flavors),
    loading: readonly(loading),
    error: readonly(error),
    
    // Computed
    hasClassicFlavors,
    hasPremiumFlavors,
    flavorCount,
    
    // Actions
    fetchByPlan,
    fetchForCurrentUser,
    fetchById,
    refresh: fetchForCurrentUser
  }
}

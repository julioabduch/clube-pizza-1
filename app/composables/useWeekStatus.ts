import type { WeekBoundsDTO } from '../../shared/types'

/**
 * Composable para obter informações da semana atual (fuso São Paulo)
 * 
 * Usa a RPC week_bounds_sp() que retorna segunda→domingo em America/Sao_Paulo
 * 
 * @example
 * const { weekStart, weekEnd, loading, refresh } = useWeekStatus()
 */
export const useWeekStatus = () => {
  const supabase = useSupabaseClient()
  
  const weekStart = ref<string | null>(null)
  const weekEnd = ref<string | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  /**
   * Busca os limites da semana atual via RPC
   */
  const fetchWeekBounds = async () => {
    loading.value = true
    error.value = null

    try {
      const { data, error: supabaseError } = await supabase
        .rpc('week_bounds_sp')

      if (supabaseError) {
        throw supabaseError
      }

      // A RPC retorna array com 1 objeto { week_start, week_end }
      if (data && Array.isArray(data) && data.length > 0) {
        const bounds = data[0] as WeekBoundsDTO
        weekStart.value = bounds.week_start
        weekEnd.value = bounds.week_end
      }
    } catch (err: any) {
      console.error('Erro ao buscar semana atual:', err)
      error.value = err.message || 'Erro ao carregar semana'
      weekStart.value = null
      weekEnd.value = null
    } finally {
      loading.value = false
    }
  }

  // Formatar datas para exibição (ex: "4 de novembro - 10 de novembro")
  const weekRange = computed(() => {
    if (!weekStart.value || !weekEnd.value) return null
    
    const start = new Date(weekStart.value)
    const end = new Date(weekEnd.value)
    
    const formatOptions: Intl.DateTimeFormatOptions = { 
      day: 'numeric', 
      month: 'long' 
    }
    
    const startFormatted = start.toLocaleDateString('pt-BR', formatOptions)
    const endFormatted = end.toLocaleDateString('pt-BR', formatOptions)
    
    return `${startFormatted} - ${endFormatted}`
  })

  // Formatar datas curtas (ex: "04/11 - 10/11")
  const weekRangeShort = computed(() => {
    if (!weekStart.value || !weekEnd.value) return null
    
    const start = new Date(weekStart.value)
    const end = new Date(weekEnd.value)
    
    const formatOptions: Intl.DateTimeFormatOptions = { 
      day: '2-digit', 
      month: '2-digit' 
    }
    
    const startFormatted = start.toLocaleDateString('pt-BR', formatOptions)
    const endFormatted = end.toLocaleDateString('pt-BR', formatOptions)
    
    return `${startFormatted} - ${endFormatted}`
  })

  return {
    // State
    weekStart: readonly(weekStart),
    weekEnd: readonly(weekEnd),
    loading: readonly(loading),
    error: readonly(error),
    
    // Computed
    weekRange,
    weekRangeShort,
    
    // Actions
    refresh: fetchWeekBounds,
    fetch: fetchWeekBounds
  }
}

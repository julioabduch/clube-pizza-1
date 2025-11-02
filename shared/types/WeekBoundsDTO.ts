// Response da RPC week_bounds_sp()
// Retorna os limites da semana atual em São Paulo (seg→dom)

export interface WeekBoundsDTO {
  week_start: string // date - segunda-feira
  week_end: string // date - domingo
}

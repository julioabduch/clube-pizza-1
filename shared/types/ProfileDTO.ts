// Tabela: profiles
// Perfil do usuário (criado automaticamente via trigger on auth.users)

export interface ProfileDTO {
  id: string // UUID - referência auth.users(id)
  full_name: string
  phone: string | null
  created_at: string
}

export interface UpdateProfileDTO {
  full_name?: string
  phone?: string | null
}

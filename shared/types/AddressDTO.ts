// Tabela: addresses
// Endereços de entrega (múltiplos por usuário)

export interface AddressDTO {
  id: string // UUID
  user_id: string // UUID - referência auth.users(id)
  name: string // ex: "Casa", "Trabalho"
  street: string
  number: string
  district: string // bairro
  city: string
  state: string | null // UF (opcional)
  zip_code: string
  phone: string | null // contato específico do endereço
  is_default: boolean
  created_at: string
}

export interface CreateAddressDTO {
  name: string
  street: string
  number: string
  district: string
  city: string
  state?: string | null
  zip_code: string
  phone?: string | null
  is_default?: boolean
}

export interface UpdateAddressDTO {
  name?: string
  street?: string
  number?: string
  district?: string
  city?: string
  state?: string | null
  zip_code?: string
  phone?: string | null
  is_default?: boolean
}

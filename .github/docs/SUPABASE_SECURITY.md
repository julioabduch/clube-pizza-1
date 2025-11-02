# 🔒 Segurança Supabase - Regras e Boas Práticas

## 📋 Checklist de Segurança

### ✅ O que DEVE ser feito

- [x] Usar `v_subscription_summary` (filtrada por `auth.uid()`) no app
- [x] Sempre validar `user.id` via `supabase.auth.getUser()` nos composables
- [x] RLS habilitado em todas as tabelas de dados de usuário
- [x] Views admin (`v_subscription_summary_admin`) sem permissões para usuários comuns
- [x] Usar `serverSupabaseServiceRole()` apenas em API routes server-side
- [x] Validar permissões antes de operações sensíveis

### ❌ O que NÃO DEVE ser feito

- [ ] Usar `v_subscription_summary_admin` no frontend/composables
- [ ] Confiar em `useSupabaseUser().value?.id` (use `auth.getUser()`)
- [ ] Expor SERVICE_ROLE key no frontend
- [ ] Desabilitar RLS em tabelas de produção
- [ ] Criar policies que permitem acesso a dados de outros usuários
- [ ] Usar `.select('*')` em views admin no client-side

---

## 🛡️ RLS (Row Level Security)

### Tabelas com RLS habilitado

```sql
-- ✅ Todas as tabelas devem ter RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
```

### Policies padrão por tabela

#### `profiles`
```sql
-- Usuário vê/edita apenas seu próprio perfil
CREATE POLICY "profiles: read own" ON profiles 
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "profiles: update own" ON profiles 
  FOR UPDATE USING (auth.uid() = id);
```

#### `subscriptions`
```sql
-- Usuário vê/cria apenas suas assinaturas
CREATE POLICY "subs: read own" ON subscriptions 
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "subs: insert own" ON subscriptions 
  FOR INSERT WITH CHECK (auth.uid() = user_id);
```

#### `orders`
```sql
-- Usuário vê/cria apenas seus pedidos
CREATE POLICY "orders: read own" ON orders 
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "orders: insert own" ON orders 
  FOR INSERT WITH CHECK (auth.uid() = user_id);
```

#### `addresses`
```sql
-- Usuário gerencia apenas seus endereços
CREATE POLICY "addresses: read own" ON addresses 
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "addresses: insert own" ON addresses 
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "addresses: update own" ON addresses 
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "addresses: delete own" ON addresses 
  FOR DELETE USING (auth.uid() = user_id);
```

---

## 🔑 Autenticação - User ID

### ❌ ERRADO
```typescript
const user = useSupabaseUser()
const userId = user.value?.id  // ❌ undefined!
```

### ✅ CORRETO
```typescript
const supabase = useSupabaseClient()
const { data: { user } } = await supabase.auth.getUser()
const userId = user?.id  // ✅ UUID correto
```

### Padrão em composables
```typescript
export const useMinhaFuncao = () => {
  const supabase = useSupabaseClient()

  const fetchData = async () => {
    // ✅ Sempre buscar user via auth.getUser()
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user?.id) {
      console.error('Usuário não autenticado')
      return null
    }

    // ✅ RLS filtra automaticamente, mas é boa prática ser explícito
    const { data } = await supabase
      .from('tabela')
      .select('*')
      .eq('user_id', user.id)
    
    return data
  }

  return { fetchData }
}
```

---

## 🚫 Views Admin - REGRAS

### `v_subscription_summary_admin`

**Uso permitido:**
- ✅ SQL Editor do Supabase (inspeção manual)
- ✅ Server API routes com SERVICE_ROLE
- ✅ Scripts de migração/seed

**Uso PROIBIDO:**
- ❌ Composables no `app/`
- ❌ Páginas Vue
- ❌ Client-side em geral
- ❌ Queries com `useSupabaseClient()`

**Configuração RLS:**
```sql
-- ❌ NUNCA criar policy que permite acesso público
-- A view admin NÃO deve ter policies para usuários comuns

-- ✅ Apenas service_role (backend) pode acessar
REVOKE ALL ON v_subscription_summary_admin FROM authenticated;
REVOKE ALL ON v_subscription_summary_admin FROM anon;
```

---

## 🔐 Service Role vs Public Key

### Public Key (SUPABASE_KEY)
- ✅ Usar no frontend
- ✅ Respeita RLS
- ✅ Limitado ao usuário autenticado
- ❌ Não pode fazer operações admin

### Service Role Key (SUPABASE_SERVICE_KEY)
- ❌ NUNCA expor no frontend
- ✅ Usar apenas em server routes
- ✅ Bypassa RLS (cuidado!)
- ✅ Pode acessar todas as tabelas

**Exemplo server-side:**
```typescript
// server/api/admin/users.get.ts
export default defineEventHandler(async (event) => {
  // ✅ Service role apenas no servidor
  const client = await serverSupabaseServiceRole(event)
  
  // Validar se é admin antes de retornar dados sensíveis
  const { data } = await client
    .from('v_subscription_summary_admin')
    .select('*')
  
  return data
})
```

---

## 🎯 RPCs Seguras

### `api_place_order` (idempotente)
```sql
CREATE OR REPLACE FUNCTION api_place_order(...)
RETURNS orders
SECURITY DEFINER  -- ✅ Roda como owner, mas valida user_id
AS $$
BEGIN
  -- ✅ Valida que subscription pertence ao usuário
  IF NOT EXISTS (
    SELECT 1 FROM subscriptions 
    WHERE id = p_subscription_id 
    AND user_id = auth.uid()  -- ✅ Filtro de segurança
  ) THEN
    RAISE EXCEPTION 'Assinatura inválida';
  END IF;
  
  -- ... resto da lógica
END;
$$;

-- ✅ Apenas authenticated pode chamar
GRANT EXECUTE ON FUNCTION api_place_order TO authenticated;
REVOKE EXECUTE ON FUNCTION api_place_order FROM anon;
```

---

## 📝 Checklist antes de Deploy

- [ ] Todas as tabelas têm RLS habilitado
- [ ] Policies testadas para cada tabela
- [ ] Views admin sem permissões para `authenticated`/`anon`
- [ ] SERVICE_KEY apenas em `.env` (não commitado)
- [ ] Composables usam `auth.getUser()` para pegar user.id
- [ ] RPCs validam `auth.uid()` antes de operações
- [ ] Nenhuma view admin usada no frontend
- [ ] Testes de segurança (tentar acessar dados de outro user)

---

## 🔍 Como Testar Segurança

### 1. Testar RLS
```sql
-- No SQL Editor, como um usuário específico:
SET request.jwt.claims.sub = 'uuid-do-usuario';

-- Tentar acessar dados de outro usuário (deve falhar)
SELECT * FROM subscriptions WHERE user_id != 'uuid-do-usuario';
```

### 2. Testar policies
```typescript
// Logar com usuário A
const userA = await supabase.auth.signInWithPassword({...})

// Tentar acessar dados do usuário B (deve retornar vazio)
const { data } = await supabase
  .from('subscriptions')
  .select('*')
  .eq('user_id', 'uuid-do-usuario-b')

console.log(data) // [] (vazio, RLS bloqueou)
```

### 3. Testar view admin
```typescript
// ❌ Deve falhar/retornar vazio
const { data, error } = await supabase
  .from('v_subscription_summary_admin')
  .select('*')

console.log(error) // "permission denied" ou similar
```

# 📊 Views do Supabase - Guia de Uso

## ⚠️ REGRAS IMPORTANTES

### 1. `v_subscription_summary` ✅ (USE NO APP)
**Propósito:** Resumo da assinatura do usuário logado  
**Filtro:** Automático por `auth.uid()` via RLS  
**Onde usar:** App (frontend), composables, páginas  
**Composable:** `useSubscriptionSummary()`

```typescript
// ✅ CORRETO - usa a view com filtro por usuário
const { data } = await supabase
  .from('v_subscription_summary')
  .select('*')
  .single()
```

**Retorna:**
- `subscription_id` - UUID da assinatura
- `plan` - 'classico' | 'premium'
- `cycle` - 'monthly' | 'quarterly'
- `weeks_used` - semanas já usadas
- `weeks_total` - total de semanas (4 ou 13)
- `week_start` - início da semana atual (segunda)
- `week_end` - fim da semana atual (domingo)
- `current_week_has_order` - boolean (já pediu?)
- `order_code` - código do pedido (se existir)

---

### 2. `v_subscription_summary_admin` ❌ (NÃO USE NO APP)
**Propósito:** Visualizar TODAS as assinaturas de TODOS os usuários  
**Filtro:** Nenhum - retorna tudo  
**Onde usar:** APENAS no SQL Editor do Supabase para administração/inspeção  
**Composable:** Nenhum - não deve ser acessada pelo app

```sql
-- ❌ NÃO USE NO APP
-- Apenas para inspeção manual no Supabase SQL Editor
SELECT * FROM v_subscription_summary_admin;
```

**⚠️ NUNCA:**
- Usar em composables
- Usar em páginas do app
- Expor via API/RPC
- Dar permissão de SELECT para roles de usuários

---

## 🔒 Segurança

### RLS (Row Level Security)

A view `v_subscription_summary` já possui RLS configurado:

```sql
-- A view filtra automaticamente por auth.uid()
-- Usuário só vê sua própria assinatura
CREATE VIEW v_subscription_summary AS
SELECT 
  s.id AS subscription_id,
  s.plan,
  s.cycle,
  -- ... outros campos
FROM subscriptions s
WHERE s.user_id = auth.uid()  -- ✅ Filtro automático
```

A view `v_subscription_summary_admin` **não tem filtro**:

```sql
-- ❌ PERIGOSO - retorna tudo
CREATE VIEW v_subscription_summary_admin AS
SELECT 
  s.id AS subscription_id,
  s.user_id,  -- expõe user_id de todos
  s.plan,
  -- ... outros campos
FROM subscriptions s
-- SEM WHERE - retorna tudo!
```

---

## 📝 Boas Práticas

### ✅ Use sempre views com filtro no app

```typescript
// Composable correto
export const useSubscriptionSummary = () => {
  const supabase = useSupabaseClient()
  
  const fetchSummary = async () => {
    const { data } = await supabase
      .from('v_subscription_summary')  // ✅ View segura
      .select('*')
      .single()
    
    return data
  }
}
```

### ❌ Nunca use views admin no app

```typescript
// ❌ ERRADO - expõe dados de todos os usuários
const { data } = await supabase
  .from('v_subscription_summary_admin')
  .select('*')
```

### ✅ Para administração, use queries server-side

Se precisar de dados admin, crie uma API Route com `serverSupabaseServiceRole()`:

```typescript
// server/api/admin/subscriptions.get.ts
export default defineEventHandler(async (event) => {
  const client = await serverSupabaseServiceRole(event)
  
  // Apenas admin pode acessar
  const { data } = await client
    .from('v_subscription_summary_admin')
    .select('*')
  
  return data
})
```

---

## 🎯 Resumo

| View | Uso | Onde | Filtro |
|------|-----|------|--------|
| `v_subscription_summary` | ✅ App/Frontend | Composables, Páginas | `auth.uid()` |
| `v_subscription_summary_admin` | ❌ Admin apenas | SQL Editor, Server API | Nenhum |

**Regra de ouro:** Se está no `app/`, use apenas `v_subscription_summary`.

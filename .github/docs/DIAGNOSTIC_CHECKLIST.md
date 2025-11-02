# 🔍 Diagnóstico Completo - Passo a Passo

Execute cada query abaixo **no SQL Editor do Supabase** e me envie os resultados.

---

## 1️⃣ Verificar usuários cadastrados

```sql
SELECT 
  id,
  email,
  created_at
FROM auth.users
ORDER BY created_at DESC;
```

**Copie os UUIDs dos 2 usuários.**

---

## 2️⃣ Verificar assinaturas

```sql
SELECT 
  s.id as subscription_id,
  s.user_id,
  u.email,
  s.plan,
  s.cycle,
  s.weeks_total,
  s.weekly_quota,
  s.active,
  s.started_at,
  s.expires_at,
  s.created_at,
  -- Status
  CASE 
    WHEN s.active = false THEN '❌ INATIVA'
    WHEN s.expires_at IS NOT NULL AND s.expires_at < CURRENT_DATE THEN '❌ EXPIRADA'
    WHEN s.started_at > CURRENT_DATE THEN '❌ AINDA NÃO COMEÇOU'
    ELSE '✅ ATIVA'
  END as status_check,
  -- Pedidos
  (SELECT COUNT(*) FROM orders WHERE subscription_id = s.id) as pedidos_feitos
FROM subscriptions s
LEFT JOIN auth.users u ON u.id = s.user_id
ORDER BY s.created_at DESC;
```

**Verifique se todos os status estão "✅ ATIVA".**

---

## 3️⃣ Verificar VIEW v_subscription_summary

```sql
-- Como ADMIN (sem filtro de usuário)
SELECT * FROM v_subscription_summary_admin;
```

**Deve retornar 2 linhas (uma para cada usuário com subscription).**

Se retornar vazio, a VIEW tem problema. Execute:

```sql
-- Ver definição da VIEW
SELECT pg_get_viewdef('v_subscription_summary_admin', true);
```

---

## 4️⃣ Verificar sabores cadastrados

```sql
SELECT 
  id,
  name,
  plan,
  active,
  created_at
FROM pizza_flavors
ORDER BY plan, name;
```

**Deve ter pelo menos:**
- 4 sabores com `plan = 'classico'`
- 4 sabores com `plan = 'premium'`
- Todos com `active = true`

---

## 5️⃣ Verificar pedidos existentes

```sql
SELECT 
  o.id,
  o.order_code,
  u.email,
  o.status,
  o.week_start,
  o.week_end,
  pf1.name as sabor_1,
  pf2.name as sabor_2,
  o.observations,
  o.created_at
FROM orders o
LEFT JOIN auth.users u ON u.id = o.user_id
LEFT JOIN pizza_flavors pf1 ON pf1.id = o.flavor_1
LEFT JOIN pizza_flavors pf2 ON pf2.id = o.flavor_2
ORDER BY o.created_at DESC;
```

**Deve mostrar 1 pedido (o que você criou manualmente).**

---

## 6️⃣ Testar RPC week_bounds_sp()

```sql
SELECT * FROM week_bounds_sp();
```

**Deve retornar:**
- `week_start` - uma segunda-feira (hoje ou anterior)
- `week_end` - o domingo correspondente

---

## 7️⃣ Ver código completo da RPC api_place_order

```sql
SELECT pg_get_functiondef('api_place_order'::regproc);
```

**Copie TODO o resultado e me envie.**

---

## 8️⃣ Testar RPC manualmente

Primeiro, pegue os IDs necessários:

```sql
SELECT 
  s.id as subscription_id,
  s.user_id,
  u.email,
  s.plan,
  pf.id as flavor_id,
  pf.name as flavor_name,
  pf.plan as flavor_plan
FROM subscriptions s
JOIN auth.users u ON u.id = s.user_id
CROSS JOIN pizza_flavors pf
WHERE s.active = true
  AND pf.active = true
  AND (
    pf.plan = s.plan 
    OR (s.plan = 'premium' AND pf.plan = 'classico')
  )
ORDER BY s.id, pf.plan, pf.name
LIMIT 10;
```

Depois, teste a RPC (substitua os UUIDs):

```sql
-- IMPORTANTE: Antes de rodar, faça login no app para ter sessão ativa
-- Ou configure o auth.uid() manualmente:

-- Opção 1: Via sessão (melhor)
-- Faça login no app primeiro, depois rode:
SELECT * FROM api_place_order(
  'UUID_DO_FLAVOR_1',
  'UUID_DO_FLAVOR_2',
  NULL,
  'Teste via SQL'
);

-- Opção 2: Forçar user_id (apenas para teste)
-- Isso só funciona se a RPC aceitar parâmetro user_id
```

---

## 9️⃣ Verificar triggers da tabela orders

```sql
SELECT 
  t.tgname as trigger_name,
  t.tgenabled as enabled,
  t.tgtype,
  p.proname as function_name
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE t.tgrelid = 'orders'::regclass;
```

**Deve ter:**
- Trigger `orders_before_insert` → `generate_order_code()`

Se não tiver, execute o código do arquivo `FIX_RPC_PLACE_ORDER.md` seção 4.

---

## 🎯 Resumo do que preciso

Para diagnosticar o problema, me envie:

1. ✅ Resultado da query #2 (assinaturas - verificar se status está "✅ ATIVA")
2. ✅ Resultado da query #3 (VIEW admin - deve ter 2 linhas)
3. ✅ Resultado da query #4 (sabores - deve ter pelo menos 8)
4. ✅ Resultado da query #7 (código completo da RPC)
5. ✅ Screenshot do erro no Console do navegador (F12) ao tentar criar pedido

Com esses dados consigo identificar exatamente onde está o problema! 🔍

# 🔍 Checklist: Pedido não foi criado

## Situação
Erro: **"Plano inválido ou limite de semanas atingido/fora da validade"**

## Diagnóstico Passo a Passo

### 1️⃣ Verificar se RPC existe e está configurada corretamente

**No SQL Editor do Supabase:**
```sql
-- Ver detalhes da função api_place_order
SELECT 
  p.proname as function_name,
  pg_get_function_result(p.oid) as return_type,
  prosecdef as is_security_definer,
  provolatile as volatility
FROM pg_proc p
WHERE p.proname = 'api_place_order';
```

**Resultado esperado:**
- `function_name`: api_place_order
- `return_type`: orders (ou "USER-DEFINED")
- `is_security_definer`: **true** ⚠️ MUITO IMPORTANTE
- `volatility`: v (volatile)

**Se `is_security_definer` = false:**
→ **Problema identificado!** A RPC não tem acesso ao `auth.uid()`
→ **Solução:** Executar `.github/docs/FIX_RPC_AUTH.sql`

---

### 2️⃣ Verificar se auth.uid() está retornando seu UUID

**No SQL Editor do Supabase:**
```sql
-- Teste simples de autenticação
SELECT auth.uid() as my_user_id;
```

**Resultado esperado:**
- Um UUID válido (ex: `a1b2c3d4-...`)

**Se retornar NULL:**
→ Você não está autenticado no SQL Editor
→ A RPC também não conseguirá pegar seu ID

**Solução:**
- Feche e reabra o SQL Editor
- Ou teste diretamente no aplicativo (console do navegador)

---

### 3️⃣ Verificar se sua subscription está válida

**No SQL Editor do Supabase:**
```sql
-- Ver sua subscription com todas as validações
SELECT 
  s.id,
  s.user_id,
  s.plan,
  s.active,
  s.started_at,
  s.expires_at,
  s.pedidos_feitos,
  s.weeks_total,
  -- Validações
  (s.active = true) as "✅ active",
  (s.expires_at IS NULL OR s.expires_at >= CURRENT_DATE) as "✅ not_expired",
  (s.started_at <= CURRENT_DATE) as "✅ started",
  (s.pedidos_feitos < s.weeks_total) as "✅ has_weeks_left",
  -- Status geral
  CASE 
    WHEN s.active = true 
      AND (s.expires_at IS NULL OR s.expires_at >= CURRENT_DATE)
      AND s.started_at <= CURRENT_DATE
      AND s.pedidos_feitos < s.weeks_total
    THEN '✅ TUDO OK'
    ELSE '❌ PROBLEMA'
  END as status
FROM subscriptions s
WHERE s.user_id = auth.uid();
```

**Resultado esperado:**
- Todos os `✅` devem ser `true`
- `status` deve ser "✅ TUDO OK"

**Se algum estiver `false`:**
→ Esse é o motivo da falha
→ Corrija os dados da subscription

---

### 4️⃣ Verificar se os sabores existem e pertencem ao plano correto

**No SQL Editor (substitua os UUIDs pelos sabores que você selecionou):**
```sql
-- Sabor 1
SELECT 
  id,
  name,
  plan,
  active
FROM pizza_flavors
WHERE id = 'UUID_DO_SABOR_1';

-- Sabor 2
SELECT 
  id,
  name,
  plan,
  active
FROM pizza_flavors
WHERE id = 'UUID_DO_SABOR_2';
```

**Verificar:**
- Os UUIDs existem?
- `active = true`?
- Se seu plano é **Clássico** → ambos sabores devem ser `plan = 'classico'`
- Se seu plano é **Premium** → pode ser qualquer sabor

---

### 5️⃣ Testar a RPC manualmente

**No SQL Editor:**
```sql
-- Testar chamando a RPC diretamente
SELECT * FROM api_place_order(
  p_flavor_1 := 'UUID_DO_SABOR_1',
  p_flavor_2 := 'UUID_DO_SABOR_2',
  p_address_id := NULL,
  p_observations := 'teste manual'
);
```

**Resultado esperado:**
- Um registro completo de `orders` com `order_code`, `status = 'pending'`, etc.

**Se der erro:**
- Leia a mensagem de erro
- Verifique os logs do PostgreSQL (Messages tab)
- Os `RAISE NOTICE` que adicionamos vão aparecer lá

---

### 6️⃣ Verificar console do navegador

**Abra o DevTools (F12) → Console**

Ao clicar em "Confirmar Pedido", deve aparecer:

```
✅ Usuário autenticado: a1b2c3d4-...
🍕 Criando pedido: { p_flavor_1: '...', p_flavor_2: '...', ... }
✅ Pedido criado com sucesso: { order_code: 'CP0001', ... }
```

**Se aparecer:**
```
❌ Usuário não autenticado - auth.getUser() retornou null
```
→ Problema de autenticação no frontend
→ Faça logout e login novamente

---

## ✅ Solução Rápida (90% dos casos)

**Execute este SQL no Supabase SQL Editor:**
```sql
-- Recriar RPC com SECURITY DEFINER e logs de debug
-- (copiar conteúdo de .github/docs/FIX_RPC_AUTH.sql)
```

**Depois, no app:**
1. Faça **logout**
2. Faça **login** novamente
3. Vá em **Dashboard** → **Monte sua Pizza**
4. Selecione os sabores
5. Confirme
6. Abra o **Console (F12)** para ver os logs

---

## 🆘 Se nada funcionar

**Envie estas informações:**

1. **Resultado do passo 1** (detalhes da RPC)
2. **Resultado do passo 2** (auth.uid())
3. **Resultado do passo 3** (validação subscription)
4. **Console do navegador** (com todos os logs)
5. **Messages do SQL Editor** (RAISE NOTICE logs)

Com essas informações conseguiremos identificar o problema exato.

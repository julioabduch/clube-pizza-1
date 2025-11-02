# 🔍 Debug de Assinatura - Checklist

## Problema: "Plano inválido ou limite de semanas atingido/fora da validade"

Este erro acontece quando a RPC `api_place_order` valida a assinatura e encontra algo errado.

---

## ✅ Checklist de Verificação no Supabase

### 1. Verificar assinatura do usuário

Execute no **SQL Editor** do Supabase:

```sql
-- Substitua pelo email do usuário que deu erro
SELECT 
  s.id,
  s.user_id,
  s.plan,
  s.cycle,
  s.weeks_total,
  s.active,
  s.started_at,
  s.expires_at,
  s.created_at,
  -- Verificar se está ativa
  CASE 
    WHEN s.active = false THEN '❌ INATIVA'
    WHEN s.expires_at IS NOT NULL AND s.expires_at < CURRENT_DATE THEN '❌ EXPIRADA'
    ELSE '✅ OK'
  END as status_check,
  -- Verificar se já excedeu semanas
  (SELECT COUNT(*) FROM orders WHERE subscription_id = s.id) as pedidos_feitos
FROM subscriptions s
JOIN auth.users u ON u.id = s.user_id
WHERE u.email = 'SEU_EMAIL_AQUI@exemplo.com';
```

**O que verificar:**
- ✅ `active` deve ser `true`
- ✅ `expires_at` deve ser `NULL` ou data futura
- ✅ `pedidos_feitos` deve ser menor que `weeks_total`
- ✅ `started_at` deve ser data passada ou hoje
- ✅ `plan` deve ser `'classico'` ou `'premium'`
- ✅ `cycle` deve ser `'monthly'` ou `'quarterly'`

---

### 2. Verificar se subscription foi criada corretamente

```sql
-- Exemplo de INSERT correto para assinatura de TESTE
INSERT INTO subscriptions (user_id, plan, cycle, weeks_total, weekly_quota, active, started_at)
VALUES (
  'UUID_DO_USUARIO',  -- Pegar do auth.users
  'premium',           -- ou 'classico'
  'monthly',           -- ou 'quarterly'
  4,                   -- 4 (mensal) ou 13 (trimestral)
  1,                   -- 1 pizza por semana
  true,                -- ativa
  CURRENT_DATE         -- começa hoje
);
```

---

### 3. Verificar campos obrigatórios

A RPC `api_place_order` valida:

```sql
-- A subscription deve ter:
-- 1. active = true
-- 2. Não estar expirada (expires_at IS NULL OR expires_at >= CURRENT_DATE)
-- 3. Não ter excedido limite de semanas
-- 4. Plano deve ser válido ('classico' ou 'premium')
```

---

### 4. Ver logs de erro completos

Abra o **DevTools do navegador** (F12) → **Console** e refaça o pedido.

Procure por:
```
🍕 Criando pedido: { ... }
❌ Erro da RPC api_place_order: { ... }
```

**Copie toda a mensagem de erro** e me envie.

---

### 5. Verificar VIEW v_subscription_summary

```sql
-- Substitua pelo email
SELECT * 
FROM v_subscription_summary
WHERE subscription_id IN (
  SELECT s.id 
  FROM subscriptions s
  JOIN auth.users u ON u.id = s.user_id
  WHERE u.email = 'SEU_EMAIL_AQUI@exemplo.com'
);
```

**Deve retornar:**
- `subscription_id` - UUID válido
- `plan` - 'classico' ou 'premium'
- `weeks_used` - menor que `weeks_total`
- `current_week_has_order` - `false` (se pode fazer pedido)

---

## 🛠️ Soluções Comuns

### Problema: `active = false`
```sql
UPDATE subscriptions 
SET active = true 
WHERE id = 'UUID_DA_SUBSCRIPTION';
```

### Problema: `expires_at` no passado
```sql
UPDATE subscriptions 
SET expires_at = NULL  -- ou data futura
WHERE id = 'UUID_DA_SUBSCRIPTION';
```

### Problema: Excedeu semanas (4 pedidos em plano mensal)
```sql
-- Aumentar limite de semanas (para teste)
UPDATE subscriptions 
SET weeks_total = 13  -- ou outro valor
WHERE id = 'UUID_DA_SUBSCRIPTION';
```

### Problema: `started_at` no futuro
```sql
UPDATE subscriptions 
SET started_at = CURRENT_DATE 
WHERE id = 'UUID_DA_SUBSCRIPTION';
```

---

## 📋 Exemplo de Assinatura VÁLIDA

```sql
-- Para criar uma assinatura de TESTE válida:

-- 1. Pegar UUID do usuário
SELECT id, email FROM auth.users WHERE email = 'seu@email.com';

-- 2. Inserir subscription
INSERT INTO subscriptions (user_id, plan, cycle, weeks_total, weekly_quota, active, started_at)
VALUES (
  'cole-o-uuid-aqui',
  'premium',
  'monthly',
  4,
  1,
  true,
  CURRENT_DATE
);

-- 3. Verificar se foi criada
SELECT * FROM v_subscription_summary;
```

---

## 🔍 Debug Avançado

Se o erro persistir, execute isso no SQL Editor:

```sql
-- Ver TODA a lógica de validação da RPC
SELECT pg_get_functiondef('api_place_order'::regproc);
```

Procure pela linha que lança a exceção:
```sql
RAISE EXCEPTION 'Plano inválido ou limite de semanas atingido/fora da validade';
```

E verifique a condição IF acima dela.

---

**Me envie:**
1. ✅ Resultado da query #1 (dados da subscription)
2. ✅ Logs do Console do navegador (erro completo)
3. ✅ Resultado da VIEW v_subscription_summary

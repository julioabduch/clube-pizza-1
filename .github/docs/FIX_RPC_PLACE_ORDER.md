# 🔧 Correção da RPC api_place_order

## Problema Identificado

A RPC `api_place_order` está executando sem erro, mas **não está retornando o pedido criado**.

Erro: `Success. No rows returned`

---

## 1. Ver código atual da RPC

Execute no SQL Editor:

```sql
SELECT pg_get_functiondef('api_place_order'::regproc);
```

Copie o resultado completo e me envie.

---

## 2. Código CORRETO da RPC

A RPC deve ter **RETURN** no final. Substitua a função inteira por esta versão:

```sql
CREATE OR REPLACE FUNCTION api_place_order(
  p_flavor_1 UUID,
  p_flavor_2 UUID DEFAULT NULL,
  p_address_id UUID DEFAULT NULL,
  p_observations TEXT DEFAULT NULL
)
RETURNS orders  -- ⚠️ IMPORTANTE: deve retornar tipo orders
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
  v_subscription_id UUID;
  v_subscription subscriptions%ROWTYPE;
  v_week_start DATE;
  v_week_end DATE;
  v_existing_order orders%ROWTYPE;
  v_new_order orders%ROWTYPE;
  v_order_count INTEGER;
BEGIN
  -- 1. Pegar user_id do usuário autenticado
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuário não autenticado';
  END IF;

  -- 2. Buscar assinatura ativa do usuário
  SELECT * INTO v_subscription
  FROM subscriptions
  WHERE user_id = v_user_id
    AND active = true
    AND (expires_at IS NULL OR expires_at >= CURRENT_DATE)
    AND started_at <= CURRENT_DATE
  LIMIT 1;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Plano inválido ou limite de semanas atingido/fora da validade';
  END IF;

  v_subscription_id := v_subscription.id;

  -- 3. Validar limite de semanas
  SELECT COUNT(*) INTO v_order_count
  FROM orders
  WHERE subscription_id = v_subscription_id;

  IF v_order_count >= v_subscription.weeks_total THEN
    RAISE EXCEPTION 'Limite de semanas atingido (% de %)', v_order_count, v_subscription.weeks_total;
  END IF;

  -- 4. Pegar semana atual (seg-dom em SP)
  SELECT week_start, week_end 
  INTO v_week_start, v_week_end
  FROM week_bounds_sp();

  -- 5. Verificar se já existe pedido nesta semana (IDEMPOTENTE)
  SELECT * INTO v_existing_order
  FROM orders
  WHERE subscription_id = v_subscription_id
    AND week_start = v_week_start
  LIMIT 1;

  IF FOUND THEN
    -- Já existe pedido - retornar o existente (idempotente)
    RETURN v_existing_order;
  END IF;

  -- 6. Validar sabores (devem existir e pertencer ao plano)
  -- Sabor 1 (obrigatório)
  IF NOT EXISTS (
    SELECT 1 FROM pizza_flavors
    WHERE id = p_flavor_1
      AND active = true
      AND (
        plan = v_subscription.plan  -- mesmo plano
        OR (v_subscription.plan = 'premium' AND plan = 'classico')  -- premium pode escolher clássico
      )
  ) THEN
    RAISE EXCEPTION 'Sabor 1 inválido ou não pertence ao plano %', v_subscription.plan;
  END IF;

  -- Sabor 2 (opcional)
  IF p_flavor_2 IS NOT NULL THEN
    IF NOT EXISTS (
      SELECT 1 FROM pizza_flavors
      WHERE id = p_flavor_2
        AND active = true
        AND (
          plan = v_subscription.plan
          OR (v_subscription.plan = 'premium' AND plan = 'classico')
        )
    ) THEN
      RAISE EXCEPTION 'Sabor 2 inválido ou não pertence ao plano %', v_subscription.plan;
    END IF;
  END IF;

  -- 7. Criar pedido (trigger vai gerar order_code)
  INSERT INTO orders (
    user_id,
    subscription_id,
    flavor_1,
    flavor_2,
    address_id,
    observations,
    status,
    week_start,
    week_end
  )
  VALUES (
    v_user_id,
    v_subscription_id,
    p_flavor_1,
    p_flavor_2,
    p_address_id,
    p_observations,
    'pending',
    v_week_start,
    v_week_end
  )
  RETURNING * INTO v_new_order;  -- ⚠️ IMPORTANTE: capturar o pedido criado

  -- 8. Retornar o pedido criado
  RETURN v_new_order;  -- ⚠️ IMPORTANTE: RETURN explícito
END;
$$;

-- Permissões
REVOKE ALL ON FUNCTION api_place_order FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api_place_order TO authenticated;
```

---

## 3. Verificar se corrigiu

Execute no SQL Editor (substitua pelos UUIDs reais):

```sql
-- Pegar UUID de um sabor clássico
SELECT id, name, plan FROM pizza_flavors WHERE plan = 'classico' LIMIT 1;

-- Testar a RPC
SELECT * FROM api_place_order(
  'UUID_DO_SABOR_CLASSICO',  -- p_flavor_1
  NULL,                       -- p_flavor_2
  NULL,                       -- p_address_id
  'Teste via SQL'             -- p_observations
);
```

**Deve retornar:** Um registro completo do pedido criado com todos os campos preenchidos.

---

## 4. Verificar trigger de order_code

O `order_code` deve ser gerado automaticamente por um trigger. Verifique se existe:

```sql
-- Ver trigger
SELECT tgname, tgtype, proname
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE tgrelid = 'orders'::regclass;
```

Se não existir, crie:

```sql
CREATE OR REPLACE FUNCTION generate_order_code()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_code TEXT;
  v_counter INTEGER;
BEGIN
  -- Gerar código único: CP + número sequencial
  SELECT COALESCE(MAX(SUBSTRING(order_code FROM 3)::INTEGER), 0) + 1
  INTO v_counter
  FROM orders;
  
  v_code := 'CP' || LPAD(v_counter::TEXT, 4, '0');
  
  NEW.order_code := v_code;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS orders_before_insert ON orders;
CREATE TRIGGER orders_before_insert
BEFORE INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION generate_order_code();
```

---

## 5. Testar no app

Após corrigir a RPC, teste no navegador:

1. Faça logout e login novamente
2. Vá para `/pedido`
3. Selecione sabores
4. Clique em "Confirmar Pedido"
5. Veja o console (F12):
   - Deve aparecer: `✅ Pedido criado com sucesso: { ... }`
   - Deve redirecionar para `/pedidoconfirmado`

---

## 🔍 Debug Adicional

Se o erro persistir:

```sql
-- Ver se o pedido foi criado mesmo sem retornar
SELECT * FROM orders
WHERE user_id = auth.uid()
ORDER BY created_at DESC
LIMIT 1;
```

Se aparecer o pedido aqui, o problema é só o RETURN da função.

---

## ✅ Checklist

- [ ] RPC tem `RETURNS orders` na assinatura
- [ ] RPC tem `RETURNING * INTO v_new_order` no INSERT
- [ ] RPC tem `RETURN v_new_order;` no final
- [ ] Trigger `generate_order_code()` existe e está ativo
- [ ] Teste via SQL retorna dados completos
- [ ] Teste no app funciona e redireciona

---

**Me envie:**
1. Resultado de `pg_get_functiondef('api_place_order'::regproc)`
2. Se o pedido aparece na tabela `orders` mesmo sem retornar

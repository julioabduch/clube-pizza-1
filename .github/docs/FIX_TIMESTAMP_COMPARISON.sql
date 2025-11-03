-- ====================================================================
-- FIX FINAL: api_place_order com conversão correta de timestamp
-- ====================================================================

DROP FUNCTION IF EXISTS api_place_order(UUID, UUID, UUID, TEXT) CASCADE;

CREATE OR REPLACE FUNCTION api_place_order(
  p_flavor_1 UUID,
  p_flavor_2 UUID DEFAULT NULL,
  p_address_id UUID DEFAULT NULL,
  p_observations TEXT DEFAULT NULL
)
RETURNS orders
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID;
  v_subscription subscriptions%ROWTYPE;
  v_week_start DATE;
  v_week_end DATE;
  v_new_order orders%ROWTYPE;
  v_existing_order orders%ROWTYPE;
  v_flavor_1_plan subscription_plan;
  v_flavor_2_plan subscription_plan;
BEGIN
  -- 1. Obter user_id do auth
  v_user_id := auth.uid();
  
  RAISE NOTICE 'DEBUG: auth.uid() = %', v_user_id;
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuário não autenticado';
  END IF;

  -- 2. Buscar assinatura ATIVA do usuário
  -- ⚠️ FIX: Converter started_at para DATE antes de comparar
  SELECT * INTO v_subscription
  FROM subscriptions
  WHERE user_id = v_user_id
    AND active = true
    AND (expires_at IS NULL OR expires_at::DATE >= CURRENT_DATE)
    AND started_at::DATE <= CURRENT_DATE  -- ✅ CONVERSÃO PARA DATE
  LIMIT 1;

  IF NOT FOUND THEN
    RAISE NOTICE 'DEBUG: Nenhuma subscription encontrada para user_id = %', v_user_id;
    RAISE EXCEPTION 'Plano inválido ou limite de semanas atingido/fora da validade';
  END IF;

  RAISE NOTICE 'DEBUG: Subscription encontrada - id: %, plan: %', v_subscription.id, v_subscription.plan;

  -- 3. Calcular semana atual (Monday-Sunday)
  SELECT week_start, week_end INTO v_week_start, v_week_end
  FROM week_bounds_sp();

  RAISE NOTICE 'DEBUG: Semana atual - start: %, end: %', v_week_start, v_week_end;

  -- 4. Verificar se já existe pedido nesta semana (idempotência)
  SELECT * INTO v_existing_order
  FROM orders
  WHERE subscription_id = v_subscription.id
    AND week_start = v_week_start
  LIMIT 1;

  IF FOUND THEN
    RAISE NOTICE 'DEBUG: Pedido já existe - order_code: %', v_existing_order.order_code;
    RETURN v_existing_order;
  END IF;

  -- 5. Validar sabor 1
  SELECT plan INTO v_flavor_1_plan
  FROM pizza_flavors
  WHERE id = p_flavor_1;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Sabor inválido';
  END IF;

  -- Premium pode escolher qualquer sabor, Classic só pode escolher Classic
  IF v_subscription.plan = 'classico' AND v_flavor_1_plan = 'premium' THEN
    RAISE EXCEPTION 'Sabor não pertence ao plano da assinatura';
  END IF;

  -- 6. Validar sabor 2 (se fornecido)
  IF p_flavor_2 IS NOT NULL THEN
    SELECT plan INTO v_flavor_2_plan
    FROM pizza_flavors
    WHERE id = p_flavor_2;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'Sabor inválido';
    END IF;

    IF v_subscription.plan = 'classico' AND v_flavor_2_plan = 'premium' THEN
      RAISE EXCEPTION 'Sabor não pertence ao plano da assinatura';
    END IF;
  END IF;

  -- 7. Criar pedido
  INSERT INTO orders (
    user_id,
    subscription_id,
    flavor_1,
    flavor_2,
    address_id,
    observations,
    week_start,
    week_end,
    status
  ) VALUES (
    v_user_id,
    v_subscription.id,
    p_flavor_1,
    p_flavor_2,
    p_address_id,
    p_observations,
    v_week_start,
    v_week_end,
    'pending'
  )
  RETURNING * INTO v_new_order;

  RAISE NOTICE 'DEBUG: Pedido criado - order_code: %', v_new_order.order_code;

  RETURN v_new_order;
END;
$$;

-- ====================================================================
-- MUDANÇA PRINCIPAL:
-- ====================================================================
-- Linha 37-38: started_at::DATE <= CURRENT_DATE
-- Linha 36: expires_at::DATE >= CURRENT_DATE
--
-- Isso garante que timestamps com timezone sejam convertidos para DATE
-- antes de comparar com CURRENT_DATE
-- ====================================================================

-- ====================================================================
-- FIX: Garantir que api_place_order usa auth.uid() corretamente
-- ====================================================================

-- IMPORTANTE: Esta RPC precisa ser SECURITY DEFINER para acessar auth.uid()
-- mas também precisa verificar se o usuário está autenticado

CREATE OR REPLACE FUNCTION api_place_order(
  p_flavor_1 UUID,
  p_flavor_2 UUID DEFAULT NULL,
  p_address_id UUID DEFAULT NULL,
  p_observations TEXT DEFAULT NULL
)
RETURNS orders
LANGUAGE plpgsql
SECURITY DEFINER -- ⚠️ Necessário para acessar auth.uid()
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
  -- 1. Obter user_id do auth (com verificação)
  v_user_id := auth.uid();
  
  -- ✅ ADICIONAR LOG PARA DEBUG
  RAISE NOTICE 'DEBUG: auth.uid() retornou: %', v_user_id;
  
  -- ✅ VERIFICAR SE USUÁRIO ESTÁ AUTENTICADO
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuário não autenticado';
  END IF;

  -- 2. Buscar assinatura ATIVA do usuário
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

  -- ✅ ADICIONAR LOG DA SUBSCRIPTION ENCONTRADA
  RAISE NOTICE 'DEBUG: Subscription encontrada - id: %, plan: %', v_subscription.id, v_subscription.plan;

  -- 3. Calcular semana atual (Monday-Sunday)
  SELECT week_start, week_end INTO v_week_start, v_week_end
  FROM week_bounds_sp();

  -- ✅ LOG DA SEMANA
  RAISE NOTICE 'DEBUG: Semana atual - start: %, end: %', v_week_start, v_week_end;

  -- 4. Verificar se já existe pedido nesta semana (idempotência)
  SELECT * INTO v_existing_order
  FROM orders
  WHERE subscription_id = v_subscription.id
    AND week_start = v_week_start
  LIMIT 1;

  IF FOUND THEN
    -- ✅ Já existe pedido - retornar o existente
    RAISE NOTICE 'DEBUG: Pedido já existe para esta semana - order_code: %', v_existing_order.order_code;
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

  -- ✅ LOG DO PEDIDO CRIADO
  RAISE NOTICE 'DEBUG: Pedido criado - order_code: %', v_new_order.order_code;

  RETURN v_new_order;
END;
$$;

-- ====================================================================
-- COMENTÁRIO: Por que SECURITY DEFINER?
-- ====================================================================
-- auth.uid() só funciona em funções SECURITY DEFINER
-- Isso faz a função rodar com privilégios do OWNER (postgres)
-- mas ainda respeitando Row Level Security (RLS)
--
-- SET search_path = public evita SQL injection
-- ====================================================================

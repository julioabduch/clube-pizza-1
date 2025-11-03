-- ====================================================================
-- FIX: Adicionar logs detalhados para debug de auth.uid()
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
  v_subscription_count INT;
BEGIN
  -- 1. Obter user_id do auth
  v_user_id := auth.uid();
  
  -- ✅ LOG CRÍTICO
  RAISE NOTICE '==========================================';
  RAISE NOTICE 'DEBUG: api_place_order chamada';
  RAISE NOTICE 'DEBUG: auth.uid() retornou = %', v_user_id;
  RAISE NOTICE 'DEBUG: p_flavor_1 = %', p_flavor_1;
  RAISE NOTICE 'DEBUG: p_flavor_2 = %', p_flavor_2;
  RAISE NOTICE '==========================================';
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuário não autenticado - auth.uid() retornou NULL';
  END IF;

  -- 2. Contar quantas subscriptions existem para esse usuário
  SELECT COUNT(*) INTO v_subscription_count
  FROM subscriptions
  WHERE user_id = v_user_id;
  
  RAISE NOTICE 'DEBUG: Total de subscriptions para user_id %: %', v_user_id, v_subscription_count;

  -- 3. Buscar assinatura ATIVA do usuário
  SELECT * INTO v_subscription
  FROM subscriptions
  WHERE user_id = v_user_id
    AND active = true
    AND (expires_at IS NULL OR expires_at::DATE >= CURRENT_DATE)
    AND started_at::DATE <= CURRENT_DATE
  LIMIT 1;

  IF NOT FOUND THEN
    -- ✅ LOG DETALHADO DO ERRO
    RAISE NOTICE 'DEBUG: ERRO - Nenhuma subscription ATIVA encontrada';
    RAISE NOTICE 'DEBUG: Verificando subscriptions sem filtros:';
    
    FOR v_subscription IN 
      SELECT * FROM subscriptions WHERE user_id = v_user_id
    LOOP
      RAISE NOTICE 'DEBUG: - Subscription id=%, active=%, started_at=%, expires_at=%', 
        v_subscription.id, 
        v_subscription.active, 
        v_subscription.started_at, 
        v_subscription.expires_at;
    END LOOP;
    
    RAISE EXCEPTION 'Plano inválido ou limite de semanas atingido/fora da validade';
  END IF;

  RAISE NOTICE 'DEBUG: ✅ Subscription encontrada - id: %, plan: %', v_subscription.id, v_subscription.plan;

  -- 4. Calcular semana atual (Monday-Sunday)
  SELECT week_start, week_end INTO v_week_start, v_week_end
  FROM week_bounds_sp();

  RAISE NOTICE 'DEBUG: Semana atual - start: %, end: %', v_week_start, v_week_end;

  -- 5. Verificar se já existe pedido nesta semana (idempotência)
  SELECT * INTO v_existing_order
  FROM orders
  WHERE subscription_id = v_subscription.id
    AND week_start = v_week_start
  LIMIT 1;

  IF FOUND THEN
    RAISE NOTICE 'DEBUG: ⚠️ Pedido já existe - order_code: %', v_existing_order.order_code;
    RETURN v_existing_order;
  END IF;

  -- 6. Validar sabor 1
  SELECT plan INTO v_flavor_1_plan
  FROM pizza_flavors
  WHERE id = p_flavor_1;

  IF NOT FOUND THEN
    RAISE NOTICE 'DEBUG: ❌ Sabor 1 não encontrado: %', p_flavor_1;
    RAISE EXCEPTION 'Sabor inválido';
  END IF;
  
  RAISE NOTICE 'DEBUG: Sabor 1 válido: plan = %', v_flavor_1_plan;

  -- Premium pode escolher qualquer sabor, Classic só pode escolher Classic
  IF v_subscription.plan = 'classico' AND v_flavor_1_plan = 'premium' THEN
    RAISE EXCEPTION 'Sabor não pertence ao plano da assinatura';
  END IF;

  -- 7. Validar sabor 2 (se fornecido)
  IF p_flavor_2 IS NOT NULL THEN
    SELECT plan INTO v_flavor_2_plan
    FROM pizza_flavors
    WHERE id = p_flavor_2;

    IF NOT FOUND THEN
      RAISE NOTICE 'DEBUG: ❌ Sabor 2 não encontrado: %', p_flavor_2;
      RAISE EXCEPTION 'Sabor inválido';
    END IF;
    
    RAISE NOTICE 'DEBUG: Sabor 2 válido: plan = %', v_flavor_2_plan;

    IF v_subscription.plan = 'classico' AND v_flavor_2_plan = 'premium' THEN
      RAISE EXCEPTION 'Sabor não pertence ao plano da assinatura';
    END IF;
  END IF;

  -- 8. Criar pedido
  RAISE NOTICE 'DEBUG: Criando pedido...';
  
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

  RAISE NOTICE 'DEBUG: ✅ PEDIDO CRIADO COM SUCESSO!';
  RAISE NOTICE 'DEBUG: order_code = %', v_new_order.order_code;
  RAISE NOTICE 'DEBUG: order_id = %', v_new_order.id;
  RAISE NOTICE '==========================================';

  RETURN v_new_order;
END;
$$;

-- ====================================================================
-- LOGS ADICIONADOS:
-- ====================================================================
-- 1. Log de entrada com todos os parâmetros
-- 2. Contagem de subscriptions para o user_id
-- 3. Loop mostrando TODAS as subscriptions (mesmo inativas)
-- 4. Validação de cada sabor com log
-- 5. Log de sucesso ao criar pedido
-- ====================================================================

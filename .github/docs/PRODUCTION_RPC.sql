-- ====================================================================
-- VERSÃO FINAL DE PRODUÇÃO: api_place_order
-- SEM logs de debug - Segura para produção
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
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuário não autenticado';
  END IF;

  -- 2. Buscar assinatura ATIVA do usuário
  SELECT * INTO v_subscription
  FROM subscriptions
  WHERE user_id = v_user_id
    AND active = true
    AND (expires_at IS NULL OR expires_at::DATE >= CURRENT_DATE)
  LIMIT 1;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Você não possui um plano ativo. Assine um plano para fazer pedidos!';
  END IF;

  -- 3. Calcular semana atual (Monday-Sunday)
  SELECT week_start, week_end INTO v_week_start, v_week_end
  FROM week_bounds_sp();

  -- 4. Verificar se já existe pedido nesta semana (idempotência)
  SELECT * INTO v_existing_order
  FROM orders
  WHERE subscription_id = v_subscription.id
    AND week_start = v_week_start
  LIMIT 1;

  IF FOUND THEN
    RETURN v_existing_order;
  END IF;

  -- 5. Validar sabor 1
  SELECT plan INTO v_flavor_1_plan
  FROM pizza_flavors
  WHERE id = p_flavor_1;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Sabor inválido. Por favor, selecione um sabor disponível.';
  END IF;

  IF v_subscription.plan = 'classico' AND v_flavor_1_plan = 'premium' THEN
    RAISE EXCEPTION 'Este sabor não está disponível no seu plano. Faça upgrade para Premium!';
  END IF;

  -- 6. Validar sabor 2 (se fornecido)
  IF p_flavor_2 IS NOT NULL THEN
    SELECT plan INTO v_flavor_2_plan
    FROM pizza_flavors
    WHERE id = p_flavor_2;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'Sabor inválido. Por favor, selecione um sabor disponível.';
    END IF;

    IF v_subscription.plan = 'classico' AND v_flavor_2_plan = 'premium' THEN
      RAISE EXCEPTION 'Este sabor não está disponível no seu plano. Faça upgrade para Premium!';
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

  RETURN v_new_order;
END;
$$;

-- Garantir permissões
GRANT EXECUTE ON FUNCTION api_place_order(UUID, UUID, UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION api_place_order(UUID, UUID, UUID, TEXT) TO anon;

-- ====================================================================
-- VERSÃO DE PRODUÇÃO - SEGURA
-- ====================================================================
-- ✅ SEM logs RAISE NOTICE (informações sensíveis)
-- ✅ Apenas mensagens de erro amigáveis para o usuário
-- ✅ SECURITY DEFINER (necessário para auth.uid())
-- ✅ SET search_path (previne SQL injection)
-- ✅ Idempotente (1 pedido por semana)
-- ✅ Cliente pode fazer pedido imediatamente após comprar plano
-- ====================================================================

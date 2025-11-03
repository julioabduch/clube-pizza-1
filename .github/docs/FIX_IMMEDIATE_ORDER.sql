-- ====================================================================
-- FIX: Permitir pedido imediato após compra do plano
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
  -- ✅ MUDANÇA: Removida validação started_at <= CURRENT_DATE
  -- Agora o cliente pode fazer pedido imediatamente após comprar o plano
  SELECT * INTO v_subscription
  FROM subscriptions
  WHERE user_id = v_user_id
    AND active = true
    AND (expires_at IS NULL OR expires_at::DATE >= CURRENT_DATE)
  LIMIT 1;

  IF NOT FOUND THEN
    RAISE NOTICE 'DEBUG: Nenhuma subscription ativa encontrada para user_id = %', v_user_id;
    RAISE EXCEPTION 'Você não possui um plano ativo. Assine um plano para fazer pedidos!';
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
    RAISE NOTICE 'DEBUG: Sabor 1 não encontrado: %', p_flavor_1;
    RAISE EXCEPTION 'Sabor inválido. Por favor, selecione um sabor disponível.';
  END IF;
  
  RAISE NOTICE 'DEBUG: Sabor 1 válido: plan = %', v_flavor_1_plan;

  -- Premium pode escolher qualquer sabor, Classic só pode escolher Classic
  IF v_subscription.plan = 'classico' AND v_flavor_1_plan = 'premium' THEN
    RAISE EXCEPTION 'Este sabor não está disponível no seu plano. Faça upgrade para Premium!';
  END IF;

  -- 6. Validar sabor 2 (se fornecido)
  IF p_flavor_2 IS NOT NULL THEN
    SELECT plan INTO v_flavor_2_plan
    FROM pizza_flavors
    WHERE id = p_flavor_2;

    IF NOT FOUND THEN
      RAISE NOTICE 'DEBUG: Sabor 2 não encontrado: %', p_flavor_2;
      RAISE EXCEPTION 'Sabor inválido. Por favor, selecione um sabor disponível.';
    END IF;
    
    RAISE NOTICE 'DEBUG: Sabor 2 válido: plan = %', v_flavor_2_plan;

    IF v_subscription.plan = 'classico' AND v_flavor_2_plan = 'premium' THEN
      RAISE EXCEPTION 'Este sabor não está disponível no seu plano. Faça upgrade para Premium!';
    END IF;
  END IF;

  -- 7. Criar pedido
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
  RAISE NOTICE '==========================================';

  RETURN v_new_order;
END;
$$;

-- Garantir permissões
GRANT EXECUTE ON FUNCTION api_place_order(UUID, UUID, UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION api_place_order(UUID, UUID, UUID, TEXT) TO anon;

-- ====================================================================
-- MUDANÇAS PRINCIPAIS:
-- ====================================================================
-- 1. ❌ REMOVIDO: AND started_at::DATE <= CURRENT_DATE
--    → Cliente pode fazer pedido imediatamente após comprar
--
-- 2. ✅ MELHORADO: Mensagens de erro mais amigáveis
--    → "Você não possui um plano ativo"
--    → "Este sabor não está disponível no seu plano"
--
-- 3. ✅ MANTIDO: Idempotência (1 pedido por semana)
--    → Evita duplicatas se clicar 2x
--
-- REGRA AGORA:
-- - Cliente compra plano → pode fazer pedido IMEDIATAMENTE
-- - Pedido válido para a semana atual (segunda a domingo)
-- - 1 pedido por semana (mesmo que compre na sexta, só 1 pizza)
-- ====================================================================

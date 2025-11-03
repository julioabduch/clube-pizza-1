-- ====================================================================
-- CRIAR APENAS A RPC api_place_order
-- Execute este arquivo se você já tem week_bounds_sp e o trigger
-- ====================================================================

-- Dropar função antiga se existir
DROP FUNCTION IF EXISTS api_place_order(UUID, UUID, UUID, TEXT) CASCADE;

-- Criar função
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
  v_subscription_id UUID;
  v_subscription subscriptions%ROWTYPE;
  v_week_start DATE;
  v_week_end DATE;
  v_existing_order orders%ROWTYPE;
  v_new_order orders%ROWTYPE;
  v_order_count INTEGER;
BEGIN
  -- 1. Auth
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuário não autenticado';
  END IF;

  -- 2. Buscar subscription ativa
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

  -- 4. Pegar semana atual
  SELECT week_start, week_end 
  INTO v_week_start, v_week_end
  FROM week_bounds_sp();

  -- 5. Verificar pedido existente (idempotente)
  SELECT * INTO v_existing_order
  FROM orders
  WHERE subscription_id = v_subscription_id
    AND week_start = v_week_start
  LIMIT 1;

  IF FOUND THEN
    RETURN v_existing_order;
  END IF;

  -- 6. Validar sabor 1
  IF NOT EXISTS (
    SELECT 1 FROM pizza_flavors
    WHERE id = p_flavor_1
      AND active = true
      AND (
        plan = v_subscription.plan
        OR (v_subscription.plan = 'premium' AND plan = 'classico')
      )
  ) THEN
    RAISE EXCEPTION 'Sabor 1 inválido ou não pertence ao plano %', v_subscription.plan;
  END IF;

  -- 7. Validar sabor 2 (opcional)
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

  -- 8. Criar pedido
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
  RETURNING * INTO v_new_order;

  -- 9. Retornar
  RETURN v_new_order;
END;
$$;

-- Permissões
COMMENT ON FUNCTION api_place_order IS 'Cria pedido semanal (idempotente)';

REVOKE ALL ON FUNCTION api_place_order FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api_place_order TO authenticated;
REVOKE EXECUTE ON FUNCTION api_place_order FROM anon;

-- Verificar
SELECT 
  routine_name,
  data_type as return_type
FROM information_schema.routines
WHERE routine_name = 'api_place_order'
  AND routine_schema = 'public';

-- Deve mostrar:
-- routine_name      | return_type
-- api_place_order   | orders

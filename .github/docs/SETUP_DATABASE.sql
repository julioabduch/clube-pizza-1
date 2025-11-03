-- ====================================================================
-- SETUP COMPLETO DO BANCO DE DADOS - Clube da Pizza
-- Execute este arquivo no SQL Editor do Supabase
-- ====================================================================

-- ============================================
-- 1. CRIAR ENUMS
-- ============================================

DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'subscription_plan') THEN
    CREATE TYPE subscription_plan AS ENUM ('classico', 'premium');
  END IF;
END $$;

DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'order_status') THEN
    CREATE TYPE order_status AS ENUM ('pending', 'preparing', 'delivered', 'cancelled');
  END IF;
END $$;

DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'billing_cycle') THEN
    CREATE TYPE billing_cycle AS ENUM ('monthly', 'quarterly');
  END IF;
END $$;

-- ============================================
-- 2. RPC: week_bounds_sp()
-- ============================================

CREATE OR REPLACE FUNCTION week_bounds_sp()
RETURNS TABLE (
  week_start DATE,
  week_end DATE
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  v_now TIMESTAMP WITH TIME ZONE;
  v_week_start DATE;
  v_week_end DATE;
BEGIN
  v_now := CURRENT_TIMESTAMP AT TIME ZONE 'America/Sao_Paulo';
  v_week_start := date_trunc('week', v_now)::DATE;
  v_week_end := v_week_start + INTERVAL '6 days';
  
  week_start := v_week_start;
  week_end := v_week_end::DATE;
  
  RETURN NEXT;
END;
$$;

COMMENT ON FUNCTION week_bounds_sp IS 'Retorna início e fim da semana atual (seg-dom) em São Paulo';

REVOKE ALL ON FUNCTION week_bounds_sp FROM PUBLIC;
GRANT EXECUTE ON FUNCTION week_bounds_sp TO authenticated;
GRANT EXECUTE ON FUNCTION week_bounds_sp TO anon;

-- ============================================
-- 3. TRIGGER: generate_order_code()
-- ============================================

CREATE OR REPLACE FUNCTION generate_order_code()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_code TEXT;
  v_counter INTEGER;
BEGIN
  IF NEW.order_code IS NOT NULL THEN
    RETURN NEW;
  END IF;
  
  SELECT COALESCE(MAX(SUBSTRING(order_code FROM 3)::INTEGER), 0) + 1
  INTO v_counter
  FROM orders
  WHERE order_code ~ '^CP[0-9]+$';
  
  v_code := 'CP' || LPAD(v_counter::TEXT, 4, '0');
  NEW.order_code := v_code;
  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION generate_order_code IS 'Gera código sequencial único (CP0001, CP0002...)';

DROP TRIGGER IF EXISTS orders_before_insert ON orders;

CREATE TRIGGER orders_before_insert
BEFORE INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION generate_order_code();

-- ============================================
-- 4. RPC: api_place_order()
-- ============================================

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

COMMENT ON FUNCTION api_place_order IS 'Cria pedido semanal (idempotente)';

REVOKE ALL ON FUNCTION api_place_order FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api_place_order TO authenticated;
REVOKE EXECUTE ON FUNCTION api_place_order FROM anon;

-- ============================================
-- 5. VERIFICAÇÕES FINAIS
-- ============================================

-- Listar funções criadas
SELECT 
  routine_name,
  routine_type,
  data_type
FROM information_schema.routines
WHERE routine_name IN ('week_bounds_sp', 'api_place_order', 'generate_order_code')
  AND routine_schema = 'public'
ORDER BY routine_name;

-- Listar triggers
SELECT 
  t.tgname as trigger_name,
  t.tgenabled as enabled,
  p.proname as function_name
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE t.tgrelid = 'orders'::regclass;

-- Testar week_bounds_sp
SELECT * FROM week_bounds_sp();

-- ============================================
-- PRONTO! ✅
-- Agora execute os seeds de sabores e subscriptions
-- ============================================

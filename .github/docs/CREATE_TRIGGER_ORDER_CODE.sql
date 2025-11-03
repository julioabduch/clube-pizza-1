-- ====================================================================
-- TRIGGER: generate_order_code
-- Descrição: Gera código único para pedidos (ex: CP0001, CP0002...)
-- ====================================================================

-- 1. CRIAR FUNÇÃO DO TRIGGER
CREATE OR REPLACE FUNCTION generate_order_code()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_code TEXT;
  v_counter INTEGER;
BEGIN
  -- Se order_code já foi fornecido, não gerar novamente
  IF NEW.order_code IS NOT NULL THEN
    RETURN NEW;
  END IF;
  
  -- Gerar código único: CP + número sequencial de 4 dígitos
  SELECT COALESCE(MAX(SUBSTRING(order_code FROM 3)::INTEGER), 0) + 1
  INTO v_counter
  FROM orders
  WHERE order_code ~ '^CP[0-9]+$';  -- apenas códigos no formato CP####
  
  v_code := 'CP' || LPAD(v_counter::TEXT, 4, '0');
  
  NEW.order_code := v_code;
  RETURN NEW;
END;
$$;

-- 2. COMENTÁRIO DA FUNÇÃO
COMMENT ON FUNCTION generate_order_code IS 'Gera código sequencial único para pedidos (CP0001, CP0002, etc)';

-- 3. CRIAR TRIGGER
DROP TRIGGER IF EXISTS orders_before_insert ON orders;

CREATE TRIGGER orders_before_insert
BEFORE INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION generate_order_code();

-- 4. VERIFICAR SE FOI CRIADO
SELECT 
  t.tgname as trigger_name,
  t.tgenabled as enabled,
  p.proname as function_name
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE t.tgrelid = 'orders'::regclass
  AND t.tgname = 'orders_before_insert';

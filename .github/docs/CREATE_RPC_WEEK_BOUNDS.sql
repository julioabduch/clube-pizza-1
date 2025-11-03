-- ====================================================================
-- RPC: week_bounds_sp
-- Descrição: Retorna início e fim da semana atual (seg-dom) em São Paulo
-- ====================================================================

-- 1. CRIAR A FUNÇÃO RPC
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
  -- Pegar data/hora atual em São Paulo
  v_now := CURRENT_TIMESTAMP AT TIME ZONE 'America/Sao_Paulo';
  
  -- Calcular início da semana (segunda-feira)
  v_week_start := date_trunc('week', v_now)::DATE;
  
  -- Calcular fim da semana (domingo)
  v_week_end := v_week_start + INTERVAL '6 days';
  
  -- Retornar
  week_start := v_week_start;
  week_end := v_week_end::DATE;
  
  RETURN NEXT;
END;
$$;

-- 2. COMENTÁRIO DA FUNÇÃO
COMMENT ON FUNCTION week_bounds_sp IS 'Retorna o início (segunda-feira) e fim (domingo) da semana atual no timezone America/Sao_Paulo';

-- 3. PERMISSÕES
REVOKE ALL ON FUNCTION week_bounds_sp FROM PUBLIC;
GRANT EXECUTE ON FUNCTION week_bounds_sp TO authenticated;
GRANT EXECUTE ON FUNCTION week_bounds_sp TO anon;

-- 4. VERIFICAR SE FOI CRIADA
SELECT 
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_name = 'week_bounds_sp'
  AND routine_schema = 'public';

-- 5. TESTAR A FUNÇÃO
SELECT * FROM week_bounds_sp();

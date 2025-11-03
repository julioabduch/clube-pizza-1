-- ====================================================================
-- DEBUG DETALHADO: Ver exatamente o que a RPC está verificando
-- ====================================================================

-- Seu user_id
-- 91d2905d-278d-4a66-a73a-a51037fe74d5

-- 1. Ver CURRENT_DATE
SELECT CURRENT_DATE as current_date;

-- 2. Ver sua subscription COM TODAS AS COMPARAÇÕES
SELECT 
  s.id,
  s.user_id,
  s.plan,
  s.active,
  s.started_at,
  s.started_at::DATE as started_at_as_date,
  s.expires_at,
  s.expires_at::DATE as expires_at_as_date,
  CURRENT_DATE,
  
  -- Testes individuais
  (s.active = true) as test_1_active,
  (s.expires_at IS NULL) as test_2a_expires_is_null,
  (s.expires_at::DATE >= CURRENT_DATE) as test_2b_expires_ok,
  (s.expires_at IS NULL OR s.expires_at::DATE >= CURRENT_DATE) as test_2_expires_total,
  (s.started_at::DATE <= CURRENT_DATE) as test_3_started,
  
  -- TESTE FINAL (o que a RPC usa)
  (
    s.active = true 
    AND (s.expires_at IS NULL OR s.expires_at::DATE >= CURRENT_DATE)
    AND s.started_at::DATE <= CURRENT_DATE
  ) as PASSA_NO_FILTRO
  
FROM subscriptions s
WHERE s.user_id = '91d2905d-278d-4a66-a73a-a51037fe74d5';

-- 3. Testar a query EXATA que a RPC usa
SELECT 
  s.id,
  s.plan,
  'Encontrou subscription!' as resultado
FROM subscriptions s
WHERE s.user_id = '91d2905d-278d-4a66-a73a-a51037fe74d5'
  AND s.active = true
  AND (s.expires_at IS NULL OR s.expires_at::DATE >= CURRENT_DATE)
  AND s.started_at::DATE <= CURRENT_DATE
LIMIT 1;

-- ====================================================================
-- DEBUG: Testar exatamente o que a RPC está vendo
-- ====================================================================

-- 1. Ver o que CURRENT_DATE retorna no Supabase
SELECT CURRENT_DATE as current_date_supabase;

-- 2. Ver sua assinatura com as comparações que a RPC faz
SELECT 
  s.id,
  s.started_at,
  s.expires_at,
  s.active,
  CURRENT_DATE as today,
  -- Testes individuais (igual na RPC)
  (s.active = true) as test_active,
  (s.expires_at IS NULL OR s.expires_at >= CURRENT_DATE) as test_expires,
  (s.started_at <= CURRENT_DATE) as test_started,
  -- Teste completo (TODAS as condições juntas)
  (
    s.active = true 
    AND (s.expires_at IS NULL OR s.expires_at >= CURRENT_DATE)
    AND s.started_at <= CURRENT_DATE
  ) as PASSA_NO_FILTRO
FROM subscriptions s
JOIN auth.users u ON u.id = s.user_id
WHERE u.email = 'SEU_EMAIL@exemplo.com';  -- ⚠️ SUBSTITUA AQUI

-- 3. Simular exatamente a query da RPC (como se fosse você logado)
-- Copie o UUID do usuário da query acima e cole abaixo:
DO $$
DECLARE
  v_user_id UUID := 'COLE_SEU_USER_ID_AQUI';  -- ⚠️ SUBSTITUA
  v_subscription subscriptions%ROWTYPE;
BEGIN
  SELECT * INTO v_subscription
  FROM subscriptions
  WHERE user_id = v_user_id
    AND active = true
    AND (expires_at IS NULL OR expires_at >= CURRENT_DATE)
    AND started_at <= CURRENT_DATE
  LIMIT 1;

  IF FOUND THEN
    RAISE NOTICE 'SUBSCRIPTION ENCONTRADA: id = %, plan = %', v_subscription.id, v_subscription.plan;
  ELSE
    RAISE NOTICE 'SUBSCRIPTION NÃO ENCONTRADA - por isso dá erro!';
  END IF;
END $$;

-- ====================================================================
-- VERIFICAR ASSINATURA DO USUÁRIO
-- ====================================================================

-- 1. Ver suas assinaturas (substitua o email)
SELECT 
  s.id as subscription_id,
  s.user_id,
  u.email,
  s.plan,
  s.cycle,
  s.weeks_total,
  s.active,
  s.started_at,
  s.expires_at,
  s.created_at,
  -- Diagnóstico
  CASE 
    WHEN s.active = false THEN '❌ active = FALSE'
    WHEN s.expires_at IS NOT NULL AND s.expires_at < CURRENT_DATE THEN '❌ EXPIRADA em ' || s.expires_at
    WHEN s.started_at > CURRENT_DATE THEN '❌ AINDA NÃO COMEÇOU (started_at no futuro)'
    ELSE '✅ VÁLIDA'
  END as diagnostico,
  -- Pedidos
  (SELECT COUNT(*) FROM orders WHERE subscription_id = s.id) as pedidos_feitos,
  s.weeks_total as limite_semanas
FROM subscriptions s
LEFT JOIN auth.users u ON u.id = s.user_id
WHERE u.email = 'SEU_EMAIL@exemplo.com'  -- ⚠️ SUBSTITUA AQUI
ORDER BY s.created_at DESC;

-- ====================================================================
-- CORREÇÕES COMUNS
-- ====================================================================

-- Se active = FALSE:
-- UPDATE subscriptions SET active = true WHERE id = 'UUID_DA_SUBSCRIPTION';

-- Se started_at está no futuro:
-- UPDATE subscriptions SET started_at = CURRENT_DATE WHERE id = 'UUID_DA_SUBSCRIPTION';

-- Se expires_at está no passado:
-- UPDATE subscriptions SET expires_at = NULL WHERE id = 'UUID_DA_SUBSCRIPTION';

-- Se excedeu limite de semanas (já fez 4 pedidos em plano mensal):
-- UPDATE subscriptions SET weeks_total = 13 WHERE id = 'UUID_DA_SUBSCRIPTION';
-- (ou deletar pedidos antigos se for teste)

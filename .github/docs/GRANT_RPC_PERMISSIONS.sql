-- ====================================================================
-- VERIFICAR E CONCEDER PERMISSÕES PARA api_place_order
-- ====================================================================

-- 1. Ver permissões atuais
SELECT 
  p.proname as function_name,
  pg_get_userbyid(p.proowner) as owner,
  p.proacl as permissions
FROM pg_proc p
WHERE p.proname = 'api_place_order';

-- 2. CONCEDER permissão de EXECUTE para authenticated users
GRANT EXECUTE ON FUNCTION api_place_order(UUID, UUID, UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION api_place_order(UUID, UUID, UUID, TEXT) TO anon;

-- 3. Verificar novamente
SELECT 
  p.proname as function_name,
  p.proacl as permissions_after_grant
FROM pg_proc p
WHERE p.proname = 'api_place_order';

-- ====================================================================
-- NOTA: Se aparecer NULL em permissions, significa que todos podem executar
-- Se aparecer algo, verificar se tem "authenticated=X" ou "anon=X"
-- ====================================================================

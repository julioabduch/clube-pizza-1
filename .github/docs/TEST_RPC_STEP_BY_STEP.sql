-- ====================================================================
-- TESTE DIRETO: Simular chamada da RPC como usuário autenticado
-- ====================================================================

-- Seu user_id: 91d2905d-278d-4a66-a73a-a51037fe74d5
-- Sabor 1 (UUID que você usou): f230c6cf-08b0-4999-be58-3b596fa4d4bd

-- ATENÇÃO: Este teste NÃO usa auth.uid(), então vamos fazer diferente
-- Vamos testar MANUALMENTE cada parte da RPC

-- 1. Verificar user_id
SELECT '91d2905d-278d-4a66-a73a-a51037fe74d5'::UUID as user_id;

-- 2. Verificar subscription (query EXATA da RPC)
SELECT 
  s.id,
  s.plan,
  s.active,
  s.started_at,
  s.started_at::DATE as started_date,
  s.expires_at,
  s.expires_at::DATE as expires_date,
  CURRENT_DATE,
  'Subscription encontrada!' as resultado
FROM subscriptions s
WHERE s.user_id = '91d2905d-278d-4a66-a73a-a51037fe74d5'
  AND s.active = true
  AND (s.expires_at IS NULL OR s.expires_at::DATE >= CURRENT_DATE)
  AND s.started_at::DATE <= CURRENT_DATE
LIMIT 1;

-- 3. Verificar sabor
SELECT 
  id,
  name,
  plan,
  active,
  'Sabor válido!' as resultado
FROM pizza_flavors
WHERE id = 'f230c6cf-08b0-4999-be58-3b596fa4d4bd';

-- 4. Verificar week_bounds_sp()
SELECT 
  week_start,
  week_end,
  'Semana calculada!' as resultado
FROM week_bounds_sp();

-- 5. Verificar se JÁ EXISTE pedido esta semana
SELECT 
  o.id,
  o.order_code,
  o.week_start,
  o.week_end,
  'JÁ EXISTE PEDIDO ESTA SEMANA!' as alerta
FROM orders o
JOIN subscriptions s ON s.id = o.subscription_id
WHERE s.user_id = '91d2905d-278d-4a66-a73a-a51037fe74d5'
  AND o.week_start = (SELECT week_start FROM week_bounds_sp())
LIMIT 1;

-- ====================================================================
-- INTERPRETAÇÃO DOS RESULTADOS:
-- ====================================================================
-- Query 2: Se retornar vazio = subscription não passa nos filtros
-- Query 3: Se retornar vazio = sabor não existe
-- Query 4: Se retornar vazio = week_bounds_sp() com problema
-- Query 5: Se retornar algo = JÁ TEM PEDIDO ESTA SEMANA (idempotência)
-- ====================================================================

-- ====================================================================
-- DEBUG: Verificar problema com started_at e CURRENT_DATE
-- ====================================================================

-- Seu user_id (substitua)
-- user_id: 91d2905d-278d-4a66-a73a-a51037fe74d5

SELECT 
  s.id,
  s.started_at,
  s.started_at::DATE as started_at_as_date,
  CURRENT_DATE as current_date,
  NOW() as now_with_timezone,
  
  -- Comparação original (que está falhando?)
  (s.started_at <= CURRENT_DATE) as "original_comparison",
  
  -- Comparação convertendo started_at para DATE
  (s.started_at::DATE <= CURRENT_DATE) as "date_comparison",
  
  -- Comparação com NOW()
  (s.started_at <= NOW()) as "timestamp_comparison",
  
  -- Ver a diferença
  CURRENT_DATE - s.started_at::DATE as "days_difference"
  
FROM subscriptions s
WHERE s.user_id = '91d2905d-278d-4a66-a73a-a51037fe74d5';

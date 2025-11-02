# 🌱 Seed de Dados para Testes

## 1. Sabores de Pizza (pizza_flavors)

Execute no **SQL Editor** do Supabase:

```sql
-- Sabores Clássicos (disponíveis para todos)
INSERT INTO pizza_flavors (name, description, plan, active) VALUES
('Calabresa', 'Mussarela e calabresa fatiada', 'classico', true),
('Frango com Catupiry', 'Mussarela, frango desfiado e catupiry', 'classico', true),
('Portuguesa', 'Mussarela, presunto, cebola, ovo e azeitona', 'classico', true),
('Marguerita', 'Mussarela, tomate, manjericão e azeite', 'classico', true);

-- Sabores Premium (apenas para assinantes premium)
INSERT INTO pizza_flavors (name, description, plan, active) VALUES
('4 Queijos', 'Mussarela, provolone, parmesão e catupiry', 'premium', true),
('Pepperoni Premium', 'Mussarela e pepperoni importado', 'premium', true),
('Trufada', 'Mussarela, cogumelos e azeite de trufa', 'premium', true),
('Carbonara', 'Creme de leite, bacon, ovo e parmesão', 'premium', true);
```

---

## 2. Criar Assinatura de Teste

### Passo 1: Pegar UUID do usuário

```sql
SELECT id, email FROM auth.users;
```

Copie o `id` (UUID) do usuário que vai testar.

### Passo 2: Criar assinatura

```sql
-- Assinatura PREMIUM MENSAL (4 semanas)
INSERT INTO subscriptions (user_id, plan, cycle, weeks_total, weekly_quota, active, started_at)
VALUES (
  'COLE_O_UUID_AQUI',  -- UUID do auth.users
  'premium',            -- 'classico' ou 'premium'
  'monthly',            -- 'monthly' (4 semanas) ou 'quarterly' (13 semanas)
  4,                    -- Total de semanas do ciclo
  1,                    -- Pizzas por semana (sempre 1)
  true,                 -- Assinatura ativa
  CURRENT_DATE          -- Data de início
);
```

**Ou para CLÁSSICO TRIMESTRAL:**

```sql
INSERT INTO subscriptions (user_id, plan, cycle, weeks_total, weekly_quota, active, started_at)
VALUES (
  'COLE_O_UUID_AQUI',
  'classico',
  'quarterly',
  13,
  1,
  true,
  CURRENT_DATE
);
```

---

## 3. Verificar se foi criado corretamente

```sql
-- Ver assinatura via VIEW (como o app vê)
SELECT * FROM v_subscription_summary;
```

**Deve retornar:**
- `subscription_id` - UUID da assinatura
- `plan` - 'classico' ou 'premium'
- `cycle` - 'monthly' ou 'quarterly'
- `weeks_used` - 0 (se ainda não fez pedidos)
- `weeks_total` - 4 ou 13
- `current_week_has_order` - false
- `order_code` - null

---

## 4. Criar Pedido Manualmente (para testar dashboard)

```sql
-- Primeiro, pegar IDs necessários
SELECT 
  s.id as subscription_id,
  s.user_id,
  pf.id as flavor_id,
  pf.name as flavor_name
FROM subscriptions s
CROSS JOIN pizza_flavors pf
WHERE s.active = true
AND pf.active = true
LIMIT 5;
```

Copie o `subscription_id` e `flavor_id` de um sabor.

```sql
-- Criar pedido via RPC (mesmo jeito que o app faz)
-- Substitua os UUIDs pelos valores reais
SELECT api_place_order(
  'UUID_DO_FLAVOR_1',      -- flavor 1 (obrigatório)
  'UUID_DO_FLAVOR_2',      -- flavor 2 (opcional, pode ser NULL)
  NULL,                     -- address_id (ainda não implementado)
  'Teste manual via SQL'    -- observações
);
```

**Ou inserir direto (NÃO RECOMENDADO - use a RPC):**

```sql
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
SELECT 
  s.user_id,
  s.id,
  (SELECT id FROM pizza_flavors WHERE plan = s.plan AND active = true LIMIT 1),
  NULL,
  NULL,
  'Teste',
  'pending',
  date_trunc('week', CURRENT_TIMESTAMP AT TIME ZONE 'America/Sao_Paulo')::date + INTERVAL '0 day',
  date_trunc('week', CURRENT_TIMESTAMP AT TIME ZONE 'America/Sao_Paulo')::date + INTERVAL '6 days'
FROM subscriptions s
WHERE s.active = true
LIMIT 1;
```

---

## 5. Limpar dados de teste

```sql
-- Deletar pedidos de teste
DELETE FROM orders WHERE observations LIKE '%teste%' OR observations LIKE '%Teste%';

-- Deletar assinaturas de teste
DELETE FROM subscriptions WHERE user_id IN (
  SELECT id FROM auth.users WHERE email LIKE '%teste%'
);

-- Deletar sabores (CUIDADO!)
-- DELETE FROM pizza_flavors;
```

---

## 📋 Checklist Final

Antes de testar o app:

- [ ] ✅ Sabores inseridos (mínimo 4 clássicos + 4 premium)
- [ ] ✅ Usuário criado via auth (login funcionando)
- [ ] ✅ Assinatura ativa criada (active = true)
- [ ] ✅ `started_at` é hoje ou no passado
- [ ] ✅ `expires_at` é NULL ou data futura
- [ ] ✅ `weeks_total` correto (4 ou 13)
- [ ] ✅ VIEW `v_subscription_summary` retorna dados

---

## 🎯 Teste Completo

1. **Login** → deve redirecionar para `/dashboard`
2. **Dashboard** → deve mostrar plano e "Pizza disponível"
3. **Clicar em "Fazer Pedido"** → redireciona para `/pedido`
4. **Página de Pedido** → lista sabores corretos:
   - Clássico: só clássicos
   - Premium: clássicos + premium
5. **Selecionar 1 ou 2 sabores** → resumo aparece
6. **Confirmar** → deve criar pedido e redirecionar para `/pedidoconfirmado`
7. **Voltar ao Dashboard** → deve mostrar "Pedido já realizado" + código

---

**Se der erro, veja:** [DEBUG_SUBSCRIPTION.md](./DEBUG_SUBSCRIPTION.md)

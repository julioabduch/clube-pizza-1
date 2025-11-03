# 🚀 Guia de Instalação - Clube da Pizza

## ⚠️ PROBLEMA IDENTIFICADO

A RPC `api_place_order` **não existe** no banco de dados, por isso retorna `Object` vazio no console.

**Erro no console:**
```
❌ Erro da RPC api_place_order: Object
```

---

## ✅ SOLUÇÃO: Executar Setup Completo

### **PASSO 1: Abrir SQL Editor no Supabase**

1. Acesse seu projeto no [Supabase](https://supabase.com)
2. Menu lateral → **SQL Editor**
3. Clique em **+ New query**

---

### **PASSO 2: Executar o Setup Completo**

Copie **TODO** o conteúdo do arquivo:

📄 `.github/docs/SETUP_DATABASE.sql`

Cole no SQL Editor e clique em **Run** (ou Ctrl+Enter).

**O script vai criar:**
- ✅ ENUMs (`subscription_plan`, `order_status`, `billing_cycle`)
- ✅ RPC `week_bounds_sp()` - retorna semana atual
- ✅ Trigger `generate_order_code()` - gera código CP0001
- ✅ RPC `api_place_order()` - **PRINCIPAL** - cria pedidos

**Resultado esperado:**
```
CREATE TYPE
CREATE FUNCTION
CREATE TRIGGER
CREATE FUNCTION
GRANT
```

---

### **PASSO 3: Verificar se Funcionou**

Execute no SQL Editor:

```sql
-- Deve listar as 3 funções
SELECT 
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_name IN ('week_bounds_sp', 'api_place_order', 'generate_order_code')
  AND routine_schema = 'public';
```

**Resultado esperado:**
| routine_name | routine_type |
|-------------|--------------|
| api_place_order | FUNCTION |
| week_bounds_sp | FUNCTION |
| generate_order_code | FUNCTION |

---

### **PASSO 4: Criar Sabores de Pizza**

Execute no SQL Editor:

```sql
-- Sabores Clássicos
INSERT INTO pizza_flavors (name, description, plan, active) VALUES
('Calabresa', 'Mussarela e calabresa fatiada', 'classico', true),
('Frango com Catupiry', 'Mussarela, frango e catupiry', 'classico', true),
('Portuguesa', 'Mussarela, presunto, cebola, ovo e azeitona', 'classico', true),
('Marguerita', 'Mussarela, tomate e manjericão', 'classico', true);

-- Sabores Premium
INSERT INTO pizza_flavors (name, description, plan, active) VALUES
('4 Queijos', 'Mussarela, provolone, parmesão e catupiry', 'premium', true),
('Pepperoni Premium', 'Mussarela e pepperoni importado', 'premium', true),
('Trufada', 'Mussarela, cogumelos e azeite de trufa', 'premium', true),
('Carbonara', 'Creme, bacon, ovo e parmesão', 'premium', true);
```

**Verificar:**
```sql
SELECT id, name, plan, active FROM pizza_flavors ORDER BY plan, name;
```

---

### **PASSO 5: Criar Assinatura de Teste**

```sql
-- 1. Pegar UUID do usuário
SELECT id, email FROM auth.users;
```

Copie o `id` do usuário que vai testar.

```sql
-- 2. Criar assinatura Premium Mensal
INSERT INTO subscriptions (user_id, plan, cycle, weeks_total, weekly_quota, active, started_at)
VALUES (
  'COLE_UUID_AQUI',  -- UUID do auth.users
  'premium',
  'monthly',
  4,
  1,
  true,
  CURRENT_DATE
);
```

**Verificar:**
```sql
SELECT * FROM v_subscription_summary_admin;
```

Deve mostrar a assinatura criada.

---

### **PASSO 6: Testar a RPC Manualmente**

```sql
-- Pegar ID de um sabor
SELECT id, name FROM pizza_flavors WHERE plan = 'classico' LIMIT 1;
```

Copie o `id` e teste a RPC:

```sql
SELECT * FROM api_place_order(
  'UUID_DO_SABOR',  -- cole aqui
  NULL,
  NULL,
  'Teste via SQL'
);
```

**Resultado esperado:**
Deve retornar um registro completo com:
- `id` - UUID do pedido
- `order_code` - Ex: "CP0001"
- `status` - "pending"
- `week_start`, `week_end` - datas da semana
- Todos os campos preenchidos

---

### **PASSO 7: Testar no App**

1. **Faça logout** e **login** novamente
2. Abra **DevTools** (F12) → **Console**
3. Vá para `/pedido`
4. Selecione 2 sabores
5. Clique em **"Confirmar Pedido"**

**Deve aparecer no console:**
```
🍕 Criando pedido: { p_flavor_1: "...", p_flavor_2: "...", ... }
✅ Pedido criado com sucesso: { id: "...", order_code: "CP0001", ... }
```

Deve redirecionar para `/pedidoconfirmado`.

---

## 🔍 Se der erro

### Erro: "Plano inválido ou limite de semanas atingido/fora da validade"

Execute:
```sql
SELECT 
  s.*,
  CASE 
    WHEN s.active = false THEN '❌ INATIVA'
    WHEN s.expires_at IS NOT NULL AND s.expires_at < CURRENT_DATE THEN '❌ EXPIRADA'
    WHEN s.started_at > CURRENT_DATE THEN '❌ NÃO COMEÇOU'
    ELSE '✅ OK'
  END as status
FROM subscriptions s
WHERE user_id = auth.uid();
```

Deve estar "✅ OK".

### Erro: "Sabor inválido..."

Verifique se o sabor existe e está ativo:
```sql
SELECT id, name, plan, active FROM pizza_flavors WHERE active = true;
```

### Ainda não funciona?

Me envie:
1. Screenshot do resultado do SQL de verificação (PASSO 3)
2. Screenshot do erro completo no Console
3. Resultado da query de assinatura

---

## 📋 Checklist Final

- [ ] SETUP_DATABASE.sql executado com sucesso
- [ ] 3 funções listadas (api_place_order, week_bounds_sp, generate_order_code)
- [ ] 8 sabores inseridos (4 clássicos + 4 premium)
- [ ] Assinatura criada e ativa
- [ ] RPC testada manualmente e retornou pedido
- [ ] App funciona e cria pedido com sucesso

---

**Após concluir, o app estará 100% funcional!** 🎉

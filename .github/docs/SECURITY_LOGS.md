# 🔒 Segurança em Produção - RPCs e Logs

## ⚠️ IMPORTANTE: Remover logs de DEBUG antes de produção

### ❌ NUNCA em produção:

```sql
RAISE NOTICE 'DEBUG: auth.uid() = %', v_user_id;
RAISE NOTICE 'DEBUG: Subscription encontrada - id: %, plan: %', v_subscription.id, v_subscription.plan;
RAISE NOTICE 'DEBUG: Sabor 1 não encontrado: %', p_flavor_1;
```

**Por quê?**
- Expõe UUIDs de usuários
- Revela estrutura do banco
- Mostra lógica de negócio
- Pode vazar informações sensíveis nos logs do PostgreSQL
- Visível no Supabase Dashboard → Logs → Postgres Logs

---

### ✅ SEMPRE em produção:

```sql
-- Apenas mensagens de erro genéricas para o usuário
RAISE EXCEPTION 'Usuário não autenticado';
RAISE EXCEPTION 'Você não possui um plano ativo';
RAISE EXCEPTION 'Sabor inválido';
```

**Por quê?**
- Mensagens claras para o usuário
- Sem informações técnicas
- Sem vazamento de IDs ou estrutura

---

## 📋 Checklist de Segurança para RPCs

### 1. SECURITY DEFINER
```sql
CREATE OR REPLACE FUNCTION minha_rpc(...)
RETURNS ...
LANGUAGE plpgsql
SECURITY DEFINER  -- ✅ Necessário para auth.uid()
SET search_path = public  -- ✅ Previne SQL injection
```

### 2. Validação de auth.uid()
```sql
v_user_id := auth.uid();

IF v_user_id IS NULL THEN
  RAISE EXCEPTION 'Usuário não autenticado';
END IF;
```

### 3. Permissões explícitas
```sql
GRANT EXECUTE ON FUNCTION minha_rpc(...) TO authenticated;
-- Não dar para 'public' ou 'anon' sem necessidade
```

### 4. Row Level Security (RLS)
- **SEMPRE** ativar RLS nas tabelas sensíveis
- Mesmo com SECURITY DEFINER, o RLS é respeitado
- Protege contra acesso direto via Supabase Client

```sql
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only see their own orders"
ON orders FOR SELECT
USING (auth.uid() = user_id);
```

---

## 🚀 Processo de Deploy Seguro

### Desenvolvimento (com logs):
1. Use `RAISE NOTICE` para debug
2. Teste localmente
3. Verifique logs no Supabase Dashboard

### Antes de Produção:
1. **REMOVA todos os `RAISE NOTICE`**
2. Execute `PRODUCTION_RPC.sql`
3. Teste novamente sem logs
4. Confirme que erro messages são user-friendly

---

## 📁 Arquivos do Projeto

### Para DEBUG (apenas desenvolvimento):
- `FIX_WITH_FULL_LOGS.sql` ❌ NÃO usar em produção
- `FIX_IMMEDIATE_ORDER.sql` ❌ Ainda tem logs
- `DEBUG_*.sql` ❌ Apenas para diagnóstico

### Para PRODUÇÃO:
- `PRODUCTION_RPC.sql` ✅ Versão final segura
- `SETUP_DATABASE.sql` ✅ Setup inicial (sem logs)

---

## 🔍 Informações Sensíveis a Proteger

### ❌ NUNCA logar:
- `auth.uid()` ou `user_id`
- IDs de subscriptions, orders, etc.
- Emails, endereços, telefones
- Valores financeiros
- Estrutura de queries SQL
- Nomes de colunas/tabelas (em excess)

### ✅ Pode logar (se necessário):
- Status genéricos ("Order created", "Payment failed")
- Timestamps
- Tipos de erros (sem detalhes)

---

## 🛡️ Logs do Frontend (Console)

Os logs no console do navegador também devem ser limpos:

### ❌ Em desenvolvimento (OK):
```typescript
console.log('✅ Usuário autenticado:', user.id)
console.log('🍕 Criando pedido:', { p_flavor_1, p_flavor_2, ... })
console.log('✅ Pedido criado:', data)
```

### ✅ Em produção:
```typescript
// Remover todos os console.log ou usar apenas:
console.info('Pedido criado com sucesso')
// Erros podem ficar (sem IDs):
console.error('Erro ao criar pedido')
```

---

## 📌 Resumo

1. **Desenvolvimento**: Use logs liberalmente para debug
2. **Antes de produção**: Execute `PRODUCTION_RPC.sql`
3. **Limpe console.log** no frontend
4. **Ative RLS** em todas as tabelas sensíveis
5. **Teste** sem logs para garantir que tudo funciona
6. **Monitore** logs de produção para detectar problemas (sem informações sensíveis)

---

## ✅ Status Atual

- ✅ RPC com logs de DEBUG criada (para desenvolvimento)
- ⚠️ **PRÓXIMO PASSO**: Executar `PRODUCTION_RPC.sql` antes de deploy
- ⚠️ **PRÓXIMO PASSO**: Remover console.log do useOrders.ts
- ✅ SECURITY DEFINER configurado
- ✅ Permissões configuradas
- ✅ Mensagens de erro user-friendly

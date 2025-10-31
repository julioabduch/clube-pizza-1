# Regras do Projeto

## Git & GitHub

### Push para GitHub
- **Branch principal**: `master`
- **Método de push**: SSH
- **Repositório remoto**: `git@github.com:julioabduch/clube-pizza-1.git`
- **Comando padrão**: `git push origin master`

Quando solicitado para fazer push/commit para o GitHub, sempre usar SSH na branch master.

## Estrutura do Projeto

### Nuxt 4
- Pasta `app/` contém toda a aplicação
- `app/pages/` para páginas
- `app/components/` para componentes
- `app/composables/` para composables

### Supabase
- Autenticação configurada
- Redirecionamento habilitado para `/login`
- Callback em `/confirm`
- **NÃO criar middlewares de autenticação** - O Supabase cuida disso automaticamente via `redirectOptions`
- Criar middleware apenas se explicitamente solicitado

## Design e UI

### Mobile-First Sempre
- **SEMPRE otimizar para celular primeiro** (design responsivo)
- Use classes Tailwind CSS responsivas: `sm:`, `md:`, `lg:`, `xl:`
- Teste em viewport mobile (320px+) antes de desktop
- Componentes devem funcionar perfeitamente em telas pequenas
- Priorize a experiência mobile em todas as decisões de design

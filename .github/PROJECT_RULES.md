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

### Nuxt UI - Biblioteca de Componentes Principal
- **SEMPRE usar componentes do Nuxt UI** para criar interfaces
- **NÃO criar componentes customizados** de UI básicos (botões, inputs, cards, etc.) - use os do Nuxt UI
- Componentes disponíveis: Button, Input, Card, Modal, Select, Checkbox, Alert, Badge, Avatar, e 100+ outros
- Use a propriedade `ui` para customizar estilos dos componentes Nuxt UI
- Layouts prontos: Header, Footer, Page, Container, DashboardSidebar, DashboardNavbar
- Formulários: use Form, FormField, Input, Select, Checkbox, RadioGroup do Nuxt UI
- Navegação: use Link, NavigationMenu, Breadcrumb, Pagination do Nuxt UI
- Overlays: use Modal, Slideover, Popover, Tooltip, DropdownMenu do Nuxt UI
- Data Display: use Table, Card, Badge, Avatar, Chip, Empty, Timeline do Nuxt UI
- Feedback: use Toast, Alert, Progress, Skeleton do Nuxt UI

### Customização de Componentes Nuxt UI
- Use a prop `ui` para customizar estilos inline: `<UButton ui="{ ... }" />`
- Use Tailwind Variants API para customizações avançadas
- Não sobrescreva estilos com CSS customizado - use o sistema de theming do Nuxt UI
- Consulte a documentação via MCP para props e customizações de cada componente

### Mobile-First Sempre
- **SEMPRE otimizar para celular primeiro** (design responsivo)
- Use classes Tailwind CSS responsivas: `sm:`, `md:`, `lg:`, `xl:`
- Teste em viewport mobile (320px+) antes de desktop
- Componentes Nuxt UI já são responsivos por padrão
- Priorize a experiência mobile em todas as decisões de design

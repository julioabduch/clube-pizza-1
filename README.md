# Clube da Pizza - Template Nuxt UI + Supabase

Um template completo para iniciar projetos com **Nuxt 4.1.3**, **Nuxt UI v4**, **@nuxtjs/supabase** e sistema de design unificado.

## 🚀 Tecnologias

- **Nuxt 4.1.3** - Framework Vue.js full-stack
- **Nuxt UI v4** - Biblioteca de componentes com design system integrado
- **@nuxtjs/supabase** - Integração com Supabase (autenticação e banco de dados)
- **Tailwind CSS v4** - Framework CSS utilitário (incluído no Nuxt UI)
- **TypeScript** - Tipagem estática
- **Vue 3.5.22** - Framework reativo

## 📋 Pré-requisitos

- Node.js (versão 18+)
- Conta no [Supabase](https://supabase.com)

## 🛠️ Configuração

1. **Clone o repositório:**
```bash
git clone <seu-repositorio>
cd template
```

2. **Instale as dependências:**
```bash
npm install
```

3. **Configure as variáveis de ambiente:**
```bash
cp .env.example .env
```

Edite o arquivo `.env` com suas credenciais do Supabase:
```env
SUPABASE_URL="https://seu-projeto.supabase.co"
SUPABASE_KEY="sua-chave-aqui"
```

## 🚀 Desenvolvimento

Inicie o servidor de desenvolvimento:

```bash
npm run dev
```

A aplicação estará disponível em `http://localhost:3000`.

## 🎨 Design System

Este projeto usa um **sistema de design unificado** baseado no Nuxt UI v4 com CSS Variables.

### Cores Principais
- **Primary (Laranja)**: `#ea580c` - Botões, CTAs, links
- **Secondary (Vermelho)**: `#dc2626` - Preços, destaques
- **Warning (Amarelo)**: `#eab308` - Badges, avisos

### Documentação Completa
Consulte o **[Design System Guide](.github/DESIGN_SYSTEM.md)** para:
- ✅ Como usar cores semânticas
- 🎯 Componentes do Nuxt UI
- 🔲 Sistema de bordas e raios
- 📝 Tipografia e hierarquia de textos
- 📐 Espaçamento e layout
- 🔧 Como alterar o design globalmente

### Exemplo de Uso

```vue
<template>
  <!-- ✅ Use cores semânticas -->
  <UButton color="primary">Ação Principal</UButton>
  
  <!-- ✅ Use componentes do Nuxt UI -->
  <UCard>
    <h1 class="text-highlighted">Título</h1>
    <p class="text-muted">Descrição</p>
  </UCard>
</template>
```

## 📜 Scripts Disponíveis

- `npm run dev` - Servidor de desenvolvimento
- `npm run build` - Build para produção
- `npm run preview` - Preview do build
- `npm run generate` - Geração de site estático

## 🔧 Configurações

### Nuxt UI
- Design System com CSS Variables configurado
- Cores semânticas: primary (laranja), secondary (vermelho), warning (amarelo)
- Componentes prontos para uso (Button, Card, Form, Alert, etc.)
- Suporte a light/dark mode

### Supabase
- Redirecionamento automático configurado para `/login`
- Suporte a cookies SSR habilitado
- Pronto para autenticação PKCE

### Tailwind CSS v4
- Incluído via Nuxt UI
- Configuração baseada em CSS Variables
- Sistema de design tokens unificado

## 📚 Documentação

- [Nuxt 4 Documentation](https://nuxt.com/docs)
- [Nuxt UI Documentation](https://ui.nuxt.com)
- [Design System Guide](.github/DESIGN_SYSTEM.md) ⭐
- [Nuxt UI Setup Guide](.github/NUXT_UI_SETUP.md)
- [@nuxtjs/supabase](https://supabase.nuxtjs.org)
- [Supabase Docs](https://supabase.com/docs)

## 📁 Estrutura do Projeto

```
template/
├── app/
│   ├── assets/css/
│   │   └── main.css              # CSS Variables e Design Tokens
│   ├── components/               # Componentes reutilizáveis
│   ├── composables/             # Composables (useAuth, etc.)
│   ├── pages/                   # Páginas da aplicação
│   └── app.vue                  # App wrapper
├── .github/
│   ├── DESIGN_SYSTEM.md         # 📘 Guia do Design System
│   └── NUXT_UI_SETUP.md         # Guia de instalação do Nuxt UI
├── app.config.ts                # Configuração de cores semânticas
├── nuxt.config.ts               # Configuração do Nuxt
└── package.json
```

## 📄 Licença

Este projeto é um template open-source. Sinta-se livre para usar e modificar.


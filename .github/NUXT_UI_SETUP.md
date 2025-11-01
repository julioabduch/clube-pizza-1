# Guia de Instalação do Nuxt UI

## Problema Comum
Se os componentes do Nuxt UI não aparecem estilizados (aparecem como HTML simples sem CSS), siga este guia.

## Causa do Problema
Conflito entre `@nuxtjs/tailwindcss` (que usa Tailwind CSS v3) e `@nuxt/ui` (que usa Tailwind CSS v4).

## Solução Passo a Passo

### 1. Instalar o Nuxt UI
```bash
npm install @nuxt/ui
```

### 2. Remover @nuxtjs/tailwindcss (se existir)
```bash
npm uninstall @nuxtjs/tailwindcss
```

**IMPORTANTE:** O `@nuxt/ui` já inclui o Tailwind CSS v4 internamente. Não é necessário instalar `@nuxtjs/tailwindcss` separadamente.

### 3. Criar arquivo CSS principal
Criar `app/assets/css/main.css`:
```css
@import "tailwindcss";
@import "@nuxt/ui";
```

### 4. Configurar nuxt.config.ts
```ts
export default defineNuxtConfig({
  modules: ['@nuxt/ui'],
  css: ['~/assets/css/main.css']
})
```

**NÃO adicione** `@nuxtjs/tailwindcss` no array de modules!

### 5. Configurar app.vue
```vue
<template>
  <UApp>
    <NuxtPage />
  </UApp>
</template>
```

### 6. Limpar cache e reiniciar
```bash
rm -rf .nuxt node_modules/.vite node_modules/.cache
npm run dev
```

## Configuração Opcional

### Cores Customizadas (app.config.ts)
```ts
export default defineAppConfig({
  ui: {
    primary: 'red',
    gray: 'neutral'
  }
})
```

### Cores Personalizadas do Tailwind (tailwind.config.ts)
```ts
import type { Config } from 'tailwindcss'

export default {
  content: [],
  theme: {
    extend: {
      colors: {
        'pizza-red': {
          50: '#fef2f2',
          100: '#fee2e2',
          // ... resto das cores
        }
      }
    }
  }
} satisfies Config
```

### VSCode IntelliSense (.vscode/settings.json)
```json
{
  "files.associations": {
    "*.css": "tailwindcss"
  },
  "editor.quickSuggestions": {
    "strings": "on"
  },
  "tailwindCSS.classAttributes": ["class", "ui"],
  "tailwindCSS.experimental.classRegex": [
    ["ui:\\s*{([^)]*)\\s*}", "(?:'|\"|`)([^']*)(?:'|\"|`)"]
  ]
}
```

## Verificação
Se tudo estiver correto, um simples botão deve aparecer estilizado:
```vue
<template>
  <UButton>Teste</UButton>
</template>
```

## Erros Comuns

### "Can't resolve 'tailwindcss'"
- **Causa:** Arquivo CSS com sintaxe incorreta ou @nuxtjs/tailwindcss instalado
- **Solução:** Remova @nuxtjs/tailwindcss e use apenas @nuxt/ui

### Componentes sem estilo
- **Causa:** CSS não está sendo importado ou conflito de módulos
- **Solução:** Verifique se `main.css` tem os imports corretos e está configurado no nuxt.config.ts

### Hydration mismatch
- **Causa:** Conteúdo dinâmico (como Math.random()) no template
- **Solução:** Evite valores que mudam entre servidor e cliente

## Resumo da Configuração Final

```
projeto/
├── app/
│   ├── assets/
│   │   └── css/
│   │       └── main.css          # @import "tailwindcss"; @import "@nuxt/ui";
│   ├── app.vue                   # <UApp><NuxtPage /></UApp>
│   └── pages/
├── app.config.ts                 # (opcional) cores customizadas
├── tailwind.config.ts            # (opcional) cores personalizadas
├── nuxt.config.ts                # modules: ['@nuxt/ui'], css: ['~/assets/css/main.css']
└── package.json                  # @nuxt/ui instalado, SEM @nuxtjs/tailwindcss
```

## Data
Guia criado em: 31 de outubro de 2025

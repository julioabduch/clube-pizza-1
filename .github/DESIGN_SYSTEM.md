# Design System - Clube da Pizza

> Sistema de design baseado no Nuxt UI v4 com CSS Variables para consistência e manutenibilidade.

## 📋 Índice

- [Cores](#cores)
- [Tipografia e Textos](#tipografia-e-textos)
- [Backgrounds](#backgrounds)
- [Bordas](#bordas)
- [Espaçamento e Layout](#espaçamento-e-layout)
- [Componentes](#componentes)
- [Boas Práticas](#boas-práticas)

---

## 🎨 Cores

### Paleta de Cores

O projeto usa 3 cores principais definidas em `app/assets/css/main.css`:

```css
/* Laranja - Cor Principal */
--color-orange-500: #f97316

/* Vermelho - Cor Secundária */
--color-red-600: #dc2626

/* Amarelo - Avisos e Destaques */
--color-yellow-500: #eab308
```

### Cores Semânticas

As cores semânticas são mapeadas via CSS Variables no `main.css`:

```css
:root {
  --ui-primary: var(--color-orange-600);      /* Laranja #ea580c */
  --ui-secondary: var(--color-red-600);       /* Vermelho #dc2626 */
  --ui-success: var(--color-orange-600);      /* Laranja (sem verde) */
  --ui-warning: var(--color-yellow-500);      /* Amarelo #eab308 */
  --ui-error: var(--color-red-600);           /* Vermelho #dc2626 */
}
```

### Como Usar Cores

#### ✅ CORRETO - Usar classes semânticas

```vue
<template>
  <!-- Texto com cor primária -->
  <h1 class="text-primary">Título</h1>
  
  <!-- Background com cor primária -->
  <div class="bg-primary">Destaque</div>
  
  <!-- Borda com cor primária -->
  <div class="border-2 border-primary">Card</div>
  
  <!-- Componentes Nuxt UI -->
  <UButton color="primary">Botão Principal</UButton>
  <UButton color="secondary">Botão Secundário</UButton>
  <UAlert color="warning">Aviso</UAlert>
</template>
```

#### ❌ ERRADO - Hardcoded colors

```vue
<!-- NÃO FAÇA ISSO -->
<h1 class="text-orange-600">Título</h1>
<UButton class="bg-red-500">Botão</UButton>
```

### Classes de Texto Disponíveis

```css
text-primary      /* Laranja - Links, CTAs, destaques */
text-secondary    /* Vermelho - Preços, ações importantes */
text-warning      /* Amarelo - Avisos */
text-error        /* Vermelho - Erros */

text-default      /* Texto padrão (#525252) */
text-highlighted  /* Texto em destaque (#171717) */
text-muted        /* Texto secundário (#737373) */
text-dimmed       /* Texto desbotado (#a3a3a3) */
text-inverted     /* Texto invertido (branco) */
```

### Alterar Cores Globalmente

Para mudar a cor primária de todo o site, edite apenas o `main.css`:

```css
/* app/assets/css/main.css */
:root {
  --ui-primary: var(--color-red-600); /* Agora vermelho é a cor principal */
}
```

Isso atualiza automaticamente:
- Todos os botões `color="primary"`
- Todas as classes `text-primary`, `bg-primary`, `border-primary`
- Todos os componentes do Nuxt UI

---

## 📝 Tipografia e Textos

### Hierarquia de Textos

```vue
<template>
  <!-- Títulos principais -->
  <h1 class="text-4xl font-bold text-highlighted">Título Principal</h1>
  
  <!-- Subtítulos -->
  <h2 class="text-2xl font-semibold text-default">Subtítulo</h2>
  
  <!-- Texto corpo -->
  <p class="text-base text-default">Texto normal do parágrafo.</p>
  
  <!-- Texto secundário -->
  <p class="text-sm text-muted">Informação adicional</p>
  
  <!-- Texto pequeno/labels -->
  <span class="text-xs text-dimmed">Label ou nota de rodapé</span>
</template>
```

### Pesos de Fonte

```css
font-light      /* 300 - Textos leves */
font-normal     /* 400 - Texto padrão */
font-medium     /* 500 - Destaque médio */
font-semibold   /* 600 - Subtítulos */
font-bold       /* 700 - Títulos principais */
```

---

## 🎯 Backgrounds

### Backgrounds Semânticos

```vue
<template>
  <!-- Background padrão (branco) -->
  <div class="bg-default">Conteúdo</div>
  
  <!-- Background suave (bege/laranja claro) -->
  <div class="bg-muted">Seção destacada</div>
  
  <!-- Background elevado (mais claro que muted) -->
  <div class="bg-elevated">Card elevado</div>
  
  <!-- Background acentuado (mais vibrante) -->
  <div class="bg-accented">Área de destaque</div>
  
  <!-- Background invertido (escuro) -->
  <div class="bg-inverted text-inverted">Footer escuro</div>
</template>
```

### Gradientes Personalizados

```vue
<template>
  <!-- Gradiente laranja suave (páginas) -->
  <div class="bg-gradient-to-br from-orange-50 via-orange-100 to-orange-200">
    Fundo de página
  </div>
  
  <!-- Gradiente laranja vibrante (cards especiais) -->
  <div class="bg-gradient-to-r from-orange-500 to-orange-600">
    Card premium
  </div>
</template>
```

---

## 🔲 Bordas

### Cores de Borda

```vue
<template>
  <!-- Borda padrão (cinza claro) -->
  <div class="border border-default">Card</div>
  
  <!-- Borda acentuada (laranja claro) -->
  <div class="border-2 border-accented">Card destacado</div>
  
  <!-- Borda com cor semântica -->
  <div class="border border-primary">Card laranja</div>
  <div class="border border-error">Card de erro</div>
</template>
```

### Raio de Borda (Border Radius)

O projeto usa `--ui-radius: 0.5rem` como padrão.

```vue
<template>
  <div class="rounded-xs">Extra pequeno (2px)</div>
  <div class="rounded-sm">Pequeno (4px)</div>
  <div class="rounded-md">Médio (6px) - PADRÃO</div>
  <div class="rounded-lg">Grande (8px)</div>
  <div class="rounded-xl">Extra grande (12px)</div>
  <div class="rounded-2xl">2X grande (16px)</div>
  <div class="rounded-full">Círculo/Pílula</div>
</template>
```

### Alterar Raio Globalmente

```css
/* app/assets/css/main.css */
:root {
  --ui-radius: 1rem; /* Bordas mais arredondadas em todo site */
}
```

---

## 📐 Espaçamento e Layout

### Espaçamento Interno (Padding)

```vue
<template>
  <div class="p-2">Padding 0.5rem (8px)</div>
  <div class="p-4">Padding 1rem (16px)</div>
  <div class="p-6">Padding 1.5rem (24px)</div>
  <div class="p-8">Padding 2rem (32px)</div>
  
  <!-- Padding específico -->
  <div class="px-4 py-2">Horizontal 16px, Vertical 8px</div>
</template>
```

### Espaçamento Externo (Margin)

```vue
<template>
  <div class="mb-4">Margin bottom 1rem</div>
  <div class="mt-8">Margin top 2rem</div>
  <div class="mx-auto">Centralizar horizontalmente</div>
</template>
```

### Gaps (Espaçamento entre elementos)

```vue
<template>
  <!-- Grid com gap -->
  <div class="grid grid-cols-3 gap-4">
    <div>Item 1</div>
    <div>Item 2</div>
    <div>Item 3</div>
  </div>
  
  <!-- Flex com gap -->
  <div class="flex gap-2">
    <button>Botão 1</button>
    <button>Botão 2</button>
  </div>
</template>
```

---

## 🧩 Componentes

### Componentes do Nuxt UI

Use sempre os componentes do Nuxt UI ao invés de criar do zero:

```vue
<template>
  <!-- Botões -->
  <UButton color="primary">Botão Principal</UButton>
  <UButton color="secondary">Botão Secundário</UButton>
  <UButton variant="outline">Botão Outline</UButton>
  <UButton variant="ghost">Botão Fantasma</UButton>
  
  <!-- Cards -->
  <UCard>
    <template #header>Cabeçalho</template>
    Conteúdo do card
    <template #footer>Rodapé</template>
  </UCard>
  
  <!-- Formulários -->
  <UForm :state="form">
    <UFormField label="Email" name="email">
      <UInput v-model="form.email" type="email" />
    </UFormField>
  </UForm>
  
  <!-- Alertas -->
  <UAlert color="warning" title="Atenção">
    Mensagem de aviso
  </UAlert>
  
  <!-- Links -->
  <ULink to="/pagina" class="text-primary">
    Link de navegação
  </ULink>
</template>
```

### Variantes de Componentes

```vue
<template>
  <!-- Botões - Variantes -->
  <UButton variant="solid">Sólido (padrão)</UButton>
  <UButton variant="outline">Contorno</UButton>
  <UButton variant="soft">Suave</UButton>
  <UButton variant="ghost">Fantasma</UButton>
  <UButton variant="link">Link</UButton>
  
  <!-- Botões - Tamanhos -->
  <UButton size="xs">Extra pequeno</UButton>
  <UButton size="sm">Pequeno</UButton>
  <UButton size="md">Médio (padrão)</UButton>
  <UButton size="lg">Grande</UButton>
  <UButton size="xl">Extra grande</UButton>
</template>
```

---

## ✅ Boas Práticas

### 1. Use Cores Semânticas

```vue
<!-- ✅ BOM -->
<UButton color="primary">Salvar</UButton>
<p class="text-primary">Destaque</p>

<!-- ❌ RUIM -->
<button class="bg-orange-600 text-white">Salvar</button>
<p class="text-orange-600">Destaque</p>
```

### 2. Use Componentes do Nuxt UI

```vue
<!-- ✅ BOM -->
<UCard>
  <UButton color="primary">Ação</UButton>
</UCard>

<!-- ❌ RUIM -->
<div class="bg-white rounded-lg shadow p-4">
  <button class="bg-orange-600 text-white px-4 py-2 rounded">Ação</button>
</div>
```

### 3. Use Classes de Texto Semânticas

```vue
<!-- ✅ BOM -->
<h1 class="text-highlighted">Título</h1>
<p class="text-default">Parágrafo</p>
<small class="text-muted">Nota</small>

<!-- ❌ RUIM -->
<h1 class="text-gray-900">Título</h1>
<p class="text-gray-700">Parágrafo</p>
<small class="text-gray-500">Nota</small>
```

### 4. Consistência de Espaçamento

Use múltiplos de 4 (escala do Tailwind):

```vue
<!-- ✅ BOM -->
<div class="p-4 mb-4 gap-4">
<div class="p-8 mb-8 gap-8">

<!-- ❌ RUIM -->
<div class="p-3 mb-5 gap-7">
```

### 5. Evite Magic Numbers

```vue
<!-- ✅ BOM -->
<div class="w-full max-w-md">      <!-- max-w-md = 28rem -->
<div class="h-screen">             <!-- altura da tela -->

<!-- ❌ RUIM -->
<div style="width: 437px">
<div style="height: 892px">
```

---

## 🔧 Como Alterar o Design System

### Mudar Cor Primária

```css
/* app/assets/css/main.css */
:root {
  --ui-primary: var(--color-red-600); /* Muda de laranja para vermelho */
}
```

### Mudar Arredondamento Global

```css
/* app/assets/css/main.css */
:root {
  --ui-radius: 0.25rem; /* Bordas mais quadradas */
}
```

### Adicionar Nova Cor Semântica

```css
/* app/assets/css/main.css */
@theme {
  --color-purple-500: #a855f7;
}

:root {
  --ui-tertiary: var(--color-purple-500);
}
```

```ts
// app.config.ts
export default defineAppConfig({
  ui: {
    colors: {
      primary: 'orange',
      secondary: 'red',
      tertiary: 'purple'  // Nova cor
    }
  }
})
```

---

## 📚 Referências

- [Nuxt UI Documentation](https://ui.nuxt.com)
- [Nuxt UI Design System](https://ui.nuxt.com/docs/getting-started/theme/design-system)
- [Nuxt UI CSS Variables](https://ui.nuxt.com/docs/getting-started/theme/css-variables)
- [Tailwind CSS](https://tailwindcss.com)

---

**Data:** 1 de novembro de 2025  
**Versão:** 1.0  
**Projeto:** Clube da Pizza - Template Nuxt UI

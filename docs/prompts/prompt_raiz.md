# Prompt — Gerador Automático de Documentação para App Mobile

## Objetivo

Desenvolva um site de documentação automática para um aplicativo mobile de lista de compras.

O site deve utilizar **arquivos Markdown (`.md`) como única fonte da verdade**, gerando automaticamente toda a estrutura de navegação, páginas e organização da documentação.

A proposta é criar uma ferramenta semelhante ao Docusaurus ou MkDocs, porém mais simples, personalizada e com sincronização entre os arquivos originais e o site.

---

# Stack obrigatória

Utilize:

- Next.js (App Router)
- TypeScript
- React
- Tailwind CSS
- remark + remark-gfm (renderização do Markdown)
- gray-matter (Front Matter)
- chokidar (monitoramento de arquivos durante desenvolvimento)

A arquitetura deve ser simples, organizada e fácil de manter.

---

# Estrutura do projeto

A documentação ficará em uma pasta chamada `docs`.

Exemplo:

```text
shopping-docs/
│
├── docs/
│   ├── index.md
│   ├── requisitos/
│   │   ├── rf-01.md
│   │   ├── rf-02.md
│   │   └── rnf.md
│   ├── arquitetura/
│   │   ├── frontend.md
│   │   └── backend.md
│   ├── casos-de-uso/
│   └── testes/
│
├── app/
├── public/
└── package.json
```

Cada pasta dentro de `docs` representa automaticamente uma seção do menu.

Não criar menus fixos.

Tudo deve ser descoberto automaticamente.

---

# Funcionamento esperado

## Leitura automática

O sistema deve:

1. Percorrer recursivamente a pasta `docs`.
2. Encontrar todos os arquivos `.md`.
3. Descobrir em qual pasta estão.
4. Gerar automaticamente:
   - menu lateral;
   - rota da página;
   - breadcrumbs;
   - ordem da documentação.

Exemplo:

`docs/requisitos/rf-01.md`

gera:

`/requisitos/rf-01`

---

## Front Matter

Cada documento pode conter:

```yaml
---
title: RF-01 - Criar Lista
order: 1
description: Permite criar uma nova lista de compras.
---
```

Campos suportados:

| Campo | Obrigatório |
|---------|------------|
| title | Sim |
| order | Não |
| description | Não |
| tags | Não |

Se `order` não existir, ordenar alfabeticamente.

---

# Renderização Markdown

Suportar:

- títulos
- listas
- tabelas
- checklists
- blocos de código
- citações
- imagens
- links internos
- links externos
- Mermaid (opcional, mas preparar arquitetura)

Utilizar `remark-gfm`.

---

# Navegação automática

O menu deve ser construído dinamicamente.

Exemplo:

```text
📖 Documentação

🏠 Início

📂 Requisitos
   • RF-01
   • RF-02
   • RNF

📂 Arquitetura
   • Frontend
   • Backend

📂 Casos de Uso

📂 Testes
```

Não escrever esse menu manualmente.

---

# Pesquisa

Criar pesquisa instantânea.

Requisitos:

- pesquisar títulos;
- pesquisar conteúdo;
- abrir diretamente a página encontrada.

Pode usar uma busca simples em memória.

---

# Sincronização automática

Durante o desenvolvimento:

- monitorar a pasta `docs` usando `chokidar`;
- quando um arquivo mudar:
  - reconstruir índice;
  - atualizar página automaticamente.

Fluxo:

```text
Editar .md
      ↓
Watcher detecta alteração
      ↓
Índice atualizado
      ↓
Página atualizada
```

Sem necessidade de upload manual.

---

# Sincronização em nuvem

---

## Modo GitHub

Fluxo:

```text
VS Code
    ↓
GitHub
    ↓
Deploy automático
    ↓
Site atualizado
```

A documentação permanece como arquivos Markdown.


---

# Editor online

Criar arquitetura preparada para edição pelo navegador.

Fluxo esperado:

```text
VS Code
     ↑
     │ sincronização
     ↓
Editor Web
```

Quando editar pelo site:

- atualizar o `.md`;
- refletir imediatamente na documentação.

Caso ainda não seja implementado, criar interfaces e estrutura preparada.

---

# Interface

Criar um layout moderno.

Requisitos:

- menu lateral recolhível;
- tema claro/escuro;
- breadcrumbs;
- página responsiva;
- tipografia confortável;
- destaque para blocos de código.

Inspirar-se em:

- Docusaurus
- VitePress
- MkDocs Material

Sem copiar o design.

---

# Requisitos Funcionais

| Código | Requisito |
|---------|-----------|
| RF01 | Ler arquivos `.md`. |
| RF02 | Criar páginas automaticamente. |
| RF03 | Organizar por pastas. |
| RF04 | Gerar menu automaticamente. |
| RF05 | Atualizar quando arquivos forem alterados. |
| RF06 | Permitir edição futura pelo site. |
| RF07 | Sincronizar alterações. |
| RF08 | Renderizar imagens e diagramas. |
| RF09 | Possuir pesquisa. |

---

# Requisitos Não Funcionais

| Código | Requisito |
|---------|-----------|
| RNF01 | Interface responsiva. |
| RNF02 | Alto desempenho. |
| RNF03 | Tema claro e escuro. |
| RNF04 | Compatível com Chrome, Edge e Firefox. |
| RNF05 | Atualização automática sem recarregar a página. |

---

# Arquitetura sugerida

```text
            Arquivos .md
                 │
                 ▼
      Scanner recursivo (docs)
                 │
                 ▼
        Organizador de páginas
                 │
       ┌─────────┴─────────┐
       ▼                   ▼
 Índice/Menu          Rotas dinâmicas
       │                   │
       └─────────┬─────────┘
                 ▼
          Renderizador Markdown
                 │
                 ▼
               Site
```

---

# Organização do código

Criar separação clara.

Exemplo:

```text
lib/
  docs.ts
  parser.ts
  navigation.ts

components/
  Sidebar.tsx
  Search.tsx
  Breadcrumb.tsx
  ThemeToggle.tsx

app/
  [...slug]/page.tsx
```

Evitar lógica duplicada.

Criar funções reutilizáveis.

---

# Boas práticas obrigatórias

- TypeScript tipado.
- Componentes pequenos.
- Código comentado apenas quando necessário.
- Funções reutilizáveis.
- Arquitetura escalável.
- Fácil manutenção.
- Preparado para futuras integrações.

---

# Resultado esperado

Ao finalizar, o projeto deve permitir que qualquer novo arquivo Markdown colocado dentro da pasta `docs` apareça automaticamente no site, com sua própria página, menu organizado, pesquisa funcionando e sincronização durante o desenvolvimento, mantendo os arquivos `.md` como fonte oficial da documentação.

## Estratégia de implementação

Implemente o projeto em fases.

Fase 1:
- Criar projeto Next.js.
- Configurar Tailwind.
- Configurar TypeScript.
- Criar estrutura base.

Fase 2:
- Scanner da pasta docs.
- Rotas dinâmicas.
- Sidebar automática.

Fase 3:
- Renderização Markdown.
- Breadcrumbs.
- Tema claro/escuro.

Fase 4:
- Pesquisa.
- Watcher com chokidar.
- Otimizações.

Ao final de cada fase:
- explique o que foi criado;
- mostre a árvore de arquivos;
- aguarde confirmação antes da próxima fase.

O scanner deve manter um índice em memória durante o desenvolvimento, evitando percorrer toda a pasta a cada requisição.
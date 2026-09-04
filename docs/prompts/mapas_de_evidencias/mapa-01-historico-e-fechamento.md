# Mapa de Evidências

- Documento: Histórico e Fechamento
- Documento associado: `docs/03-modulos/historico-e-fechamento.md`
- Versão: v1.0
- Status: Draft
- Persona-Version: persona-08
- Last_update_date: 2026-06-24

---

# 1. Objetivo

Este documento registra todas as evidências utilizadas na elaboração do documento
`historico-e-fechamento.md`.

Seu objetivo é garantir rastreabilidade entre os documentos do projeto,
permitindo identificar a origem de cada informação utilizada.

---

# 2. Convenção

Todas as evidências seguem o formato:

```
EV-HIST-XXX
```

onde:

- EV → Evidência
- HIST → Documento Histórico e Fechamento
- XXX → Sequencial

Exemplo:

```
EV-HIST-001
EV-HIST-002
...
```

---

# 3. Tabela de Evidências

| ID | Documento de Origem | Seção de Origem | Informação utilizada | Utilizada em |
|----|---------------------|-----------------|---------------------|--------------|
| EV-HIST-001 | visao-do-produto.md | Objetivo | O produto permite finalizar listas de compras. | Objetivo |
| EV-HIST-002 | visao-do-produto.md | Escopo | Histórico de compras faz parte do escopo. | Escopo |
| EV-HIST-003 | visao-do-produto.md | Funcionalidades | Consulta de histórico. | Fluxo Consultar Histórico |
| EV-HIST-004 | visao-do-produto.md | Escopo | Autenticação está fora deste módulo. | Fora do escopo |
| EV-HIST-005 | visao-do-produto.md | Escopo | Nota fiscal pertence a outro módulo. | Fora do escopo |
| EV-HIST-006 | visao-do-produto.md | Escopo | Controle de estoque pertence a outro módulo. | Fora do escopo |
| EV-HIST-007 | visao-do-produto.md | Funcionalidades | Compartilhamento. | Integrações |
| EV-HIST-008 | visao-do-produto.md | Atores | Usuário. | Atores |
| EV-HIST-009 | visao-do-produto.md | Atores | Sistema. | Atores |
| EV-HIST-010 | visao-do-produto.md | Regras | Cada usuário acessa apenas seus próprios dados. | RN-HIST-006 |
| EV-HIST-011 | compras.md | Objetivo | O fechamento encerra a compra. | Objetivo |
| EV-HIST-012 | compras.md | Fluxo 6.5 | Fluxo de Finalizar Compra. | Fluxo Finalizar Compra |
| EV-HIST-013 | compras.md | Entidade ShoppingList | Estrutura da lista. | Entidades |
| EV-HIST-014 | compras.md | Entidade ShoppingItem | Estrutura dos itens. | Entidades |
| EV-HIST-015 | compras.md | Regras RN-COMP-012 | Apenas listas ativas podem ser finalizadas. | RN-HIST-001 |
| EV-HIST-016 | compras.md | Regras RN-COMP-013 | Lista finalizada gera histórico. | RN-HIST-003 |
| EV-HIST-017 | compras.md | Estados | Lista ativa/finalizada. | Estados |
| EV-HIST-018 | compras.md | Integrações | Integração com Banco de Dados. | Integrações |
| EV-HIST-019 | compras.md | Integrações | Integração com Compartilhamento. | Integrações |
| EV-HIST-020 | compras.md | Eventos | shopping_list_closed. | Eventos |
| EV-HIST-021 | glossario.md | Histórico | Definição de histórico. | Objetivo |
| EV-HIST-022 | glossario.md | Compra finalizada | Definição. | Fluxos |
| EV-HIST-023 | glossario.md | Resumo da compra | Definição. | Resumo |
| EV-HIST-024 | glossario.md | Total realizado | Definição. | Resumo |
| EV-HIST-025 | glossario.md | Item comprado | Definição. | Resumo |
| EV-HIST-026 | glossario.md | Item pendente | Definição. | Resumo |
| EV-HIST-027 | glossario.md | PurchaseHistory | Entidade. | Entidades |
| EV-HIST-028 | requisitos-funcionais.md | REQ-FUNC-023 | Manter histórico. | Fluxos |
| EV-HIST-029 | requisitos-funcionais.md | REQ-FUNC-024 | Fechar compra. | Fluxos |
| EV-HIST-030 | requisitos-funcionais.md | REQ-FUNC-025 | Gerar resumo. | Fluxos |

---

# 4. Estatísticas

| Item | Quantidade |
|------|-----------:|
| Evidências totais | 30 |
| Visão do Produto | 10 |
| Compras | 10 |
| Glossário | 7 |
| Requisitos Funcionais | 3 |

---

# 5. Validação

- [x] Todas as evidências possuem identificador único.
- [x] Todas possuem documento de origem.
- [x] Todas possuem seção de origem.
- [x] Todas indicam onde foram utilizadas.
- [x] Não existem evidências duplicadas.

---

# 6. Convenções Futuras

Ao adicionar novas evidências utilizar sempre o próximo número sequencial.

Exemplo:

```
EV-HIST-031
EV-HIST-032
EV-HIST-033
...
```

Nunca reutilizar um identificador removido.

Caso uma evidência deixe de ser utilizada, mantê-la registrada com status **Obsoleta**, preservando a rastreabilidade histórica.

---

FIM
# Módulo de Histórico e Fechamento

## Metadados do Documento (obrigatório)

- **Projeto:** `lista_compras`
- **Documento gerado em:** `2026-06-24 00:00`
- **Status:** `v1.0-draft (DOC-LISTA-COMPRAS-HIST-FECH-v1)`
- **Responsável técnico:** `Equipe de Produto / Engenharia`
- **Persona-Version:** `persona-08`
- **prompt-usado:** `prompt-01-historico-e-fechamento.md`
- **Evidence-Map-Output:** `docs/99-prompts/prompts-euderlan/99-mapas_de_evidencias/mapa-01-historico-e-fechamento.md`

> Estes metadados devem ser mantidos no início do documento para fins de rastreabilidade, auditoria e governança documental.

---

## 1. Objetivo

O módulo de **Histórico e Fechamento** é responsável por permitir que o usuário finalize uma lista de compras, gere um resumo da compra e preserve os dados da compra finalizada para consulta posterior.

Este módulo complementa o módulo de compras, pois recebe listas finalizadas, consolida informações relevantes e mantém o registro histórico da compra. O produto prevê que o usuário possa finalizar listas, consultar histórico e reaproveitar informações de compras anteriores. **Evidência(s):** `EV-01-VISAO001`, `EV-01-COMP001`, `EV-01-REQ001`.

---

## 2. Escopo

### 2.1 Dentro do escopo

| Item | Descrição | Evidência(s) |
|---|---|---|
| Finalizar compra | Permitir o fechamento de uma lista ativa. | `EV-01-COMP002`, `EV-01-REQ002` |
| Gerar resumo | Consolidar total, itens comprados e itens pendentes. | `EV-01-REQ003` |
| Registrar histórico | Preservar a lista finalizada em histórico consultável. | `EV-01-VISAO002`, `EV-01-COMP002`, `EV-01-REQ001` |
| Consultar histórico | Permitir que o usuário consulte compras finalizadas. | `EV-01-VISAO003`, `EV-01-REQ001` |
| Visualizar detalhes | Permitir acesso aos dados preservados de uma compra histórica. | `EV-01-REQ001` |

### 2.2 Fora do escopo

| Item | Motivo | Evidência(s) |
|---|---|---|
| Autenticação | A autenticação pertence ao módulo próprio de autenticação. | `EV-01-VISAO004` |
| Criação e edição de listas ativas | Pertence ao módulo de compras. | `EV-01-COMP003` |
| Parser completo de nota fiscal | Pertence ao módulo de nota fiscal. | `EV-01-VISAO005` |
| Gestão avançada de estoque | Está fora do escopo inicial do produto. | `EV-01-VISAO006` |
| Notificações push | Pertence ao módulo de notificações. | `EV-01-VISAO007` |
| Relatórios financeiros avançados | Está fora do escopo do módulo de compras e não foi definido como escopo deste módulo. | `EV-01-COMP004` |

---

## 3. Responsabilidades do módulo

| Responsabilidade | Descrição | Evidência(s) |
|---|---|---|
| Receber lista finalizada | Receber dados de uma lista ativa no momento do fechamento. | `EV-01-COMP002` |
| Validar fechamento | Garantir que apenas listas elegíveis sejam fechadas. | `EV-01-COMP005` |
| Consolidar resumo | Calcular e preservar total, itens comprados, itens pendentes e data de fechamento. | `EV-01-REQ003` |
| Registrar histórico | Manter histórico das listas de compras concluídas ou fechadas. | `EV-01-REQ001` |
| Consultar compras finalizadas | Disponibilizar consulta de compras anteriores ao usuário. | `EV-01-VISAO003` |
| Preservar rastreabilidade | Manter vínculo entre lista, itens e dados consolidados. | `EV-01-GLOSS001`, `EV-01-GLOSS002` |
| Integrar com outros módulos | Apoiar integração com compras, estoque, nota fiscal, compartilhamento, banco e notificações. | `EV-01-COMP006` |

---

## 4. Atores

| Ator | Responsabilidade no módulo | Evidência(s) |
|---|---|---|
| Usuário | Finalizar listas, confirmar fechamento e consultar histórico. | `EV-01-VISAO008`, `EV-01-REQ002` |
| Sistema | Calcular resumo, alterar status da lista, registrar histórico e validar permissões. | `EV-01-VISAO009`, `EV-01-COMP002` |
| Módulo de Compras | Origem da lista ativa que será finalizada. | `EV-01-COMP001`, `EV-01-COMP002` |
| Serviço de Backend | Persistir dados de listas, itens e histórico quando sincronização estiver habilitada. | `EV-01-COMP007` |
| Módulo de Compartilhamento | Compartilhar resumo ou lista finalizada quando acionado. | `EV-01-VISAO010`, `EV-01-COMP006` |

---

## 5. Entidades

### 5.1 ShoppingList

Representa uma lista de compras criada pelo usuário. No contexto deste módulo, a entidade é usada principalmente quando seu status passa de `ativa` para `finalizada`.

| Campo | Tipo sugerido | Obrigatório | Descrição | Evidência(s) |
|---|---|---:|---|---|
| id | uuid/string | Sim | Identificador único da lista. | `EV-01-COMP008` |
| user_id | uuid/string | Sim | Identificador do usuário proprietário. | `EV-01-COMP008` |
| nome | string | Sim | Nome da lista. | `EV-01-COMP008` |
| status | enum | Sim | Estado da lista: `ativa`, `finalizada` ou `arquivada`. | `EV-01-COMP008`, `EV-01-GLOSS003` |
| total_estimado | decimal | Não | Total calculado com base nos itens. | `EV-01-COMP008` |
| total_realizado | decimal | Não | Total consolidado no fechamento. | `EV-01-COMP008`, `EV-01-GLOSS004` |
| created_at | datetime | Sim | Data de criação. | `EV-01-COMP008` |
| updated_at | datetime | Sim | Data da última atualização. | `EV-01-COMP008` |
| closed_at | datetime | Não | Data de fechamento. | `EV-01-COMP008` |

### 5.2 ShoppingItem

Representa item associado a uma lista de compras. No fechamento, seus dados devem ser preservados para permitir consulta histórica.

| Campo | Tipo sugerido | Obrigatório | Descrição | Evidência(s) |
|---|---|---:|---|---|
| id | uuid/string | Sim | Identificador único do item. | `EV-01-COMP009` |
| list_id | uuid/string | Sim | Lista à qual o item pertence. | `EV-01-COMP009` |
| category_id | uuid/string | Não | Categoria associada ao item. | `EV-01-COMP009` |
| nome | string | Sim | Nome do item. | `EV-01-COMP009` |
| quantidade | decimal | Não | Quantidade planejada ou comprada. | `EV-01-COMP009` |
| unidade | string | Não | Unidade de medida. | `EV-01-COMP009` |
| preco_unitario | decimal | Não | Preço por unidade. | `EV-01-COMP009` |
| preco_total | decimal | Não | Preço total do item. | `EV-01-COMP009` |
| comprado | boolean | Sim | Indica se o item foi comprado. | `EV-01-COMP009`, `EV-01-GLOSS005` |
| observacao | string | Não | Observações livres do usuário. | `EV-01-COMP009` |

### 5.3 PurchaseHistory

Representa uma compra finalizada armazenada para consulta futura.

| Campo | Tipo sugerido | Obrigatório | Descrição | Evidência(s) |
|---|---|---:|---|---|
| id | uuid/string | Sim | Identificador único do registro histórico. | `EV-01-GLOSS002` |
| list_id | uuid/string | Sim | Lista de compras que originou o histórico. | `EV-01-GLOSS002` |
| user_id | uuid/string | Sim | Usuário proprietário do histórico. | `EV-01-VISAO011` |
| total_final | decimal | Não | Total final consolidado. | `EV-01-GLOSS002`, `EV-01-GLOSS004` |
| data_fechamento | datetime | Sim | Data e hora em que a compra foi finalizada. | `EV-01-GLOSS002` |
| itens_comprados | integer | Não | Quantidade de itens marcados como comprados. | `EV-01-REQ003` |
| itens_pendentes | integer | Não | Quantidade de itens não comprados no fechamento. | `EV-01-REQ003` |
| created_at | datetime | Sim | Data de criação do registro histórico. | `EV-01-GLOSS002` |

---

## 6. Fluxos principais

### 6.1 Finalizar compra

1. O usuário abre uma lista ativa.
2. O usuário seleciona a ação de finalizar compra.
3. O sistema exibe confirmação de fechamento.
4. O usuário confirma o fechamento.
5. O sistema calcula o resumo final.
6. O sistema altera o status da lista para `finalizada`.
7. O sistema registra a compra no histórico.
8. O sistema exibe confirmação de fechamento.

**Evidência(s):** `EV-01-COMP002`, `EV-01-REQ002`.

#### Regras aplicáveis

- `RN-HIST-001`: somente listas ativas podem ser finalizadas.
- `RN-HIST-002`: o fechamento deve exigir confirmação do usuário.
- `RN-HIST-003`: lista finalizada deve gerar registro consultável no histórico.

---

### 6.2 Gerar resumo

1. O sistema recebe a lista a ser finalizada.
2. O sistema identifica os itens associados à lista.
3. O sistema identifica itens comprados e itens pendentes.
4. O sistema calcula ou recupera o total da compra.
5. O sistema consolida o resumo da compra.
6. O sistema associa o resumo ao registro histórico.

**Evidência(s):** `EV-01-REQ003`, `EV-01-COMP010`.

#### Dados mínimos do resumo

| Dado | Descrição | Evidência(s) |
|---|---|---|
| Total da compra | Total consolidado após a compra ser finalizada. | `EV-01-GLOSS004`, `EV-01-REQ003` |
| Itens comprados | Itens marcados como comprados durante a compra. | `EV-01-GLOSS005`, `EV-01-REQ003` |
| Itens pendentes | Itens não marcados como comprados. | `EV-01-GLOSS006`, `EV-01-REQ003` |
| Data de fechamento | Data em que a lista foi finalizada. | `EV-01-COMP008`, `EV-01-GLOSS002` |

---

### 6.3 Registrar histórico

1. O sistema valida que a lista foi finalizada.
2. O sistema preserva os dados da lista finalizada.
3. O sistema preserva itens e totais associados.
4. O sistema cria ou atualiza o registro de histórico.
5. O sistema disponibiliza o registro para consulta posterior.

**Evidência(s):** `EV-01-REQ001`, `EV-01-VISAO002`, `EV-01-COMP005`.

---

### 6.4 Consultar histórico

1. O usuário acessa a área de histórico.
2. O sistema carrega as compras finalizadas pertencentes ao usuário autenticado.
3. O sistema exibe a lista de compras históricas.
4. O usuário seleciona uma compra histórica.
5. O sistema exibe os detalhes da compra selecionada.

**Evidência(s):** `EV-01-VISAO003`, `EV-01-REQ001`, `EV-01-VISAO011`.

---

### 6.5 Visualizar detalhes da compra histórica

1. O usuário seleciona uma compra finalizada no histórico.
2. O sistema recupera a lista, itens e resumo preservados.
3. O sistema exibe total, itens comprados, itens pendentes e data de fechamento.
4. O sistema impede edição pelo fluxo comum de compras quando a lista estiver finalizada.

**Evidência(s):** `EV-01-REQ001`, `EV-01-REQ003`, `EV-01-COMP005`.

---

## 7. Regras de negócio

| ID | Regra | Descrição | Impacto | Exceções | Evidência(s) |
|---|---|---|---|---|---|
| RN-HIST-001 | Fechar somente lista ativa | Apenas listas com status `ativa` podem ser finalizadas. | Impede fechamento duplicado ou inconsistente. | Reabertura futura deve ser definida em fluxo específico. | `EV-01-COMP005`, `EV-01-GLOSS003` |
| RN-HIST-002 | Confirmação obrigatória | O usuário deve confirmar antes de concluir o fechamento. | Reduz fechamento acidental. | Não definida nesta versão. | `EV-01-COMP002`, `EV-01-REQ002` |
| RN-HIST-003 | Preservação no histórico | Toda lista finalizada deve gerar registro consultável no histórico. | Garante consulta futura da compra finalizada. | Não definida nesta versão. | `EV-01-COMP005`, `EV-01-REQ001` |
| RN-HIST-004 | Preservação de itens e totais | O histórico deve preservar itens e totais associados à compra finalizada. | Mantém rastreabilidade da compra. | Não definida nesta versão. | `EV-01-REQ001` |
| RN-HIST-005 | Lista finalizada não editável | Lista finalizada não deve ser editada pelo fluxo comum de compras. | Evita alteração indevida de dados históricos. | Fluxo futuro de reabertura deve ser especificado. | `EV-01-COMP005` |
| RN-HIST-006 | Histórico por usuário | O usuário só pode consultar histórico de sua propriedade. | Garante isolamento de dados. | Não definida nesta versão. | `EV-01-VISAO011`, `EV-01-COMP011` |
| RN-HIST-007 | Resumo no fechamento | O resumo deve ser gerado ao finalizar uma lista. | Garante visão consolidada da compra. | Não definida nesta versão. | `EV-01-REQ003` |
| RN-HIST-008 | Itens pendentes no resumo | Itens pendentes devem ser exibidos quando existirem. | Permite identificar o que não foi comprado. | Não definida nesta versão. | `EV-01-REQ003`, `EV-01-GLOSS006` |
| RN-HIST-009 | Total final | O total final deve ser registrado no histórico quando disponível. | Permite consulta futura do custo da compra. | Itens sem preço válido não devem impedir cálculo dos demais itens. | `EV-01-GLOSS004`, `EV-01-COMP010` |
| RN-HIST-010 | Data de fechamento | Toda compra finalizada deve registrar data de fechamento. | Permite ordenação e consulta cronológica. | Não definida nesta versão. | `EV-01-COMP008`, `EV-01-GLOSS002` |

---

## 8. Estados

### 8.1 Estados da lista de compras

| Estado | Descrição | Permite edição pelo fluxo comum? | Evidência(s) |
|---|---|---:|---|
| ativa | Lista em uso, editável e visível na área principal. | Sim | `EV-01-GLOSS003`, `EV-01-COMP012` |
| finalizada | Lista encerrada e registrada no histórico. | Não | `EV-01-GLOSS003`, `EV-01-COMP012` |
| arquivada | Lista antiga mantida sem destaque. | Não definido nesta versão. | `EV-01-GLOSS003`, `EV-01-COMP012` |

### 8.2 Estados do item no histórico

| Estado | Descrição | Evidência(s) |
|---|---|---|
| comprado | Item comprado pelo usuário. | `EV-01-GLOSS005` |
| pendente | Item ainda não comprado no momento do fechamento. | `EV-01-GLOSS006` |

---

## 9. Integrações

| Módulo | Objetivo da integração | Evidência(s) |
|---|---|---|
| Compras | Receber lista ativa, itens, totais e status de fechamento. | `EV-01-COMP001`, `EV-01-COMP002` |
| Banco de dados | Persistir listas, itens, categorias e histórico. | `EV-01-COMP007` |
| Autenticação | Identificar o usuário dono das listas e histórico. | `EV-01-COMP006`, `EV-01-VISAO011` |
| Nota Fiscal | Associar documento fiscal à compra quando recurso estiver disponível. | `EV-01-COMP006`, `EV-01-VISAO005` |
| Estoque | Atualizar ou sugerir itens de estoque a partir da compra. | `EV-01-COMP006` |
| Notificações | Disparar lembretes ou eventos relacionados a listas ou itens. | `EV-01-COMP006`, `EV-01-VISAO007` |
| Compartilhamento WhatsApp | Compartilhar lista ou resumo formatado. | `EV-01-VISAO010`, `EV-01-COMP006` |

---

## 10. Casos de uso relacionados

| Caso de Uso | Nome | RF Relacionado | Descrição | Evidência(s) |
|---|---|---|---|---|
| UC-HIST-001 | Consultar histórico | REQ-FUNC-023 | Usuário consulta compras finalizadas. | `EV-01-REQ001` |
| UC-HIST-002 | Fechar compra | REQ-FUNC-024 | Usuário finaliza lista de compras. | `EV-01-REQ002` |
| UC-HIST-003 | Gerar resumo | REQ-FUNC-025 | Sistema gera resumo da compra ao finalizar a lista. | `EV-01-REQ003` |
| UC-HIST-004 | Visualizar detalhes históricos | REQ-FUNC-023 | Usuário consulta detalhes de uma compra histórica. | `EV-01-REQ001` |

---

## 11. Critérios de aceite

| ID | Critério | Verificação | Evidência(s) |
|---|---|---|---|
| CA-HIST-001 | O usuário deve conseguir finalizar uma lista ativa. | Dada uma lista ativa, quando confirmar fechamento, então o sistema deve marcar a lista como finalizada. | `EV-01-REQ002`, `EV-01-COMP002` |
| CA-HIST-002 | O sistema deve exigir confirmação antes do fechamento. | Quando o usuário acionar finalizar, então o sistema deve exibir confirmação antes de concluir. | `EV-01-REQ002`, `EV-01-COMP002` |
| CA-HIST-003 | A lista finalizada deve gerar histórico. | Após fechamento, deve existir registro consultável no histórico. | `EV-01-REQ001`, `EV-01-COMP005` |
| CA-HIST-004 | O resumo deve exibir total da compra. | Após fechamento, o resumo deve mostrar total quando houver valores válidos. | `EV-01-REQ003`, `EV-01-GLOSS004` |
| CA-HIST-005 | O resumo deve exibir itens comprados. | Após fechamento, o resumo deve exibir quantidade ou relação de itens comprados. | `EV-01-REQ003`, `EV-01-GLOSS005` |
| CA-HIST-006 | O resumo deve exibir itens pendentes quando existirem. | Após fechamento, itens não comprados devem aparecer como pendentes. | `EV-01-REQ003`, `EV-01-GLOSS006` |
| CA-HIST-007 | O histórico deve preservar itens e totais. | Ao consultar compra histórica, itens e totais associados devem estar disponíveis. | `EV-01-REQ001` |
| CA-HIST-008 | O usuário não deve acessar histórico de outro usuário. | Ao tentar acessar histórico sem permissão, o sistema deve negar acesso. | `EV-01-VISAO011`, `EV-01-COMP011` |
| CA-HIST-009 | Lista finalizada não deve ser editada pelo fluxo comum. | Ao abrir uma lista finalizada, ações comuns de edição devem estar bloqueadas ou indisponíveis. | `EV-01-COMP005` |

---

## 12. Telas sugeridas

| Tela | Objetivo | Elementos principais | Evidência(s) |
|---|---|---|---|
| Resumo de fechamento | Confirmar finalização da compra. | Total, itens comprados, pendentes, confirmar. | `EV-01-COMP013` |
| Histórico de compras | Exibir compras finalizadas. | Lista de compras históricas, data, total, busca/filtro futuro. | `EV-01-VISAO003`, `EV-01-REQ001` |
| Detalhe da compra histórica | Exibir dados preservados da compra. | Itens, total, itens comprados, pendentes, data de fechamento. | `EV-01-REQ001`, `EV-01-REQ003` |

---

## 13. Eventos funcionais sugeridos

| Evento | Quando ocorre | Uso futuro | Evidência(s) |
|---|---|---|---|
| shopping_list_closed | Compra finalizada. | Histórico, resumo, estoque. | `EV-01-COMP014` |
| purchase_summary_generated | Resumo gerado no fechamento. | Exibição, compartilhamento, auditoria funcional. | `EV-01-REQ003` |
| purchase_history_created | Registro histórico criado. | Consulta futura e sincronização. | `EV-01-REQ001` |
| purchase_history_viewed | Usuário abriu histórico ou detalhe. | Analytics e melhoria de UX. | `EV-01-VISAO003` |

---

## 14. Pendências para refinamento

| Pendência | Descrição | Evidência(s) |
|---|---|---|
| `[ADICIONAR: regra de reabertura de lista finalizada]` | Definir se uma lista finalizada poderá voltar para o estado ativa. | `EV-01-PEND001` |
| `[ADICIONAR: política de exclusão de histórico]` | Definir se registros históricos poderão ser excluídos, arquivados ou apenas ocultados. | `EV-01-PEND002` |
| `[ADICIONAR: filtros do histórico]` | Definir filtros por data, total, categoria, mercado ou texto. | `EV-01-PEND003` |
| `[ADICIONAR: vínculo definitivo entre nota fiscal e histórico]` | Definir se o histórico armazenará URL fiscal, chave de acesso ou dados extraídos. | `EV-01-PEND004` |
| `[ADICIONAR: atualização de estoque após fechamento]` | Definir se o fechamento atualiza estoque automaticamente ou apenas sugere alterações. | `EV-01-PEND005` |
| `[ADICIONAR: formato final do resumo compartilhável]` | Definir o texto exato usado no compartilhamento por WhatsApp. | `EV-01-PEND006` |

---

## 15. Referências relacionadas

- `docs/01-visao-geral/visao-do-produto.md`
- `docs/01-visao-geral/glossario.md`
- `docs/01-visao-geral/requisitos-funcionais.md`
- `docs/03-modulos/compras.md`
- `docs/03-modulos/nota-fiscal.md`
- `docs/03-modulos/controle-de-estoque.md`
- `docs/03-modulos/compartilhamento-whatsapp.md`
- `docs/04-banco-de-dados/esquema-er.md`
- `docs/05-contratos-de-api/tabelas-supabase.md`

---

## 16. Checklist Final (QA)

- [x] Objetivo descrito.
- [x] Escopo dentro e fora do módulo documentado.
- [x] Responsabilidades documentadas.
- [x] Atores identificados.
- [x] Entidades descritas.
- [x] Fluxos principais documentados.
- [x] Regras de negócio numeradas.
- [x] Estados documentados.
- [x] Integrações documentadas.
- [x] Casos de uso relacionados.
- [x] Critérios de aceite definidos.
- [x] Pendências identificadas com `[ADICIONAR: ...]`.
- [x] Terminologia consistente com Glossário.
- [x] Documento pronto para arquitetura.
- [x] Documento pronto para banco de dados.
- [x] Documento pronto para APIs.
- [x] Documento pronto para implementação.
- [x] Documento pronto para testes.

---

## 17. Validação de Rastreabilidade e Metadados

| Item | Status |
|---|---|
| Cada informação relevante possui ID de evidência. | OK |
| Cada ID de evidência deve aparecer no mapa de evidência associado. | Pendente até criação do mapa. |
| Metadados obrigatórios foram preenchidos no início do documento. | OK |
| Persona-Version e prompt-usado foram informados. | OK |
| Pendências foram marcadas com `[ADICIONAR: ...]`. | OK |

---

FIM

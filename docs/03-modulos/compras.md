# Módulo de Compras

- Documento: Especificação do Módulo de Compras
- Versão: v1.0
- Owners: Equipe de Produto / Engenharia
- Last_update_date: 2026-06-20
- Status: Draft

---

## 1. Objetivo

O módulo de compras é o núcleo funcional do aplicativo `lista_compras`. Ele permite que o usuário crie listas de compras, adicione itens, organize itens por categoria, informe quantidades e preços, marque itens como comprados, visualize totais e finalize a compra para registro no histórico.

Este módulo deve ser simples para uso cotidiano, mas estruturado para integração futura com nota fiscal, estoque, notificações, compartilhamento e sincronização em backend.

---

## 2. Escopo

### 2.1 Dentro do escopo

- Criar lista de compras.
- Editar lista de compras.
- Excluir lista de compras.
- Listar listas ativas.
- Adicionar item a uma lista.
- Editar item de uma lista.
- Remover item de uma lista.
- Marcar item como comprado ou pendente.
- Associar item a uma categoria.
- Informar quantidade, unidade e preço.
- Calcular total da lista.
- Exibir progresso da compra.
- Finalizar lista de compras.
- Enviar lista finalizada para histórico.
- Compartilhar lista ou resumo com outros aplicativos.

### 2.2 Fora do escopo do módulo

- Autenticação do usuário.
- Persistência detalhada de políticas RLS.
- Parser completo de nota fiscal.
- Gestão avançada de estoque.
- Notificações push.
- Relatórios financeiros avançados.
- Comparação automática de preços entre mercados.

---

## 3. Atores

| Ator | Responsabilidade |
|---|---|
| Usuário | Criar, editar, acompanhar, compartilhar e finalizar listas de compras. |
| Sistema | Persistir dados, calcular totais, validar permissões e atualizar estados. |
| Serviço de Backend | Armazenar listas, itens, categorias e histórico quando sincronização estiver habilitada. |
| Módulo de Histórico | Receber dados de compras finalizadas. |
| Módulo de Compartilhamento | Enviar lista ou resumo para WhatsApp ou outro aplicativo. |

---

## 4. Entidades do módulo

### 4.1 Lista de Compras

Representa uma compra planejada ou em execução.

Campos sugeridos:

| Campo | Tipo sugerido | Obrigatório | Descrição |
|---|---|---:|---|
| id | uuid/string | Sim | Identificador único da lista. |
| user_id | uuid/string | Sim | Identificador do usuário proprietário. |
| nome | string | Sim | Nome da lista. |
| status | enum | Sim | Estado da lista: ativa, finalizada ou arquivada. |
| total_estimado | decimal | Não | Total calculado com base nos itens. |
| total_realizado | decimal | Não | Total consolidado no fechamento. |
| created_at | datetime | Sim | Data de criação. |
| updated_at | datetime | Sim | Data da última atualização. |
| closed_at | datetime | Não | Data de fechamento. |

### 4.2 Item de Compra

Representa um produto ou entrada dentro de uma lista.

Campos sugeridos:

| Campo | Tipo sugerido | Obrigatório | Descrição |
|---|---|---:|---|
| id | uuid/string | Sim | Identificador único do item. |
| list_id | uuid/string | Sim | Lista à qual o item pertence. |
| category_id | uuid/string | Não | Categoria associada ao item. |
| nome | string | Sim | Nome do item. |
| quantidade | decimal | Não | Quantidade planejada ou comprada. |
| unidade | string | Não | Unidade de medida. |
| preco_unitario | decimal | Não | Preço por unidade. |
| preco_total | decimal | Não | Preço total do item. |
| comprado | boolean | Sim | Indica se o item foi comprado. |
| observacao | string | Não | Observações livres do usuário. |
| created_at | datetime | Sim | Data de criação. |
| updated_at | datetime | Sim | Data da última atualização. |

### 4.3 Categoria

Representa agrupamento visual e lógico dos itens.

Campos sugeridos:

| Campo | Tipo sugerido | Obrigatório | Descrição |
|---|---|---:|---|
| id | uuid/string | Sim | Identificador único da categoria. |
| user_id | uuid/string | Sim | Usuário proprietário da categoria. |
| nome | string | Sim | Nome da categoria. |
| cor | string | Não | Cor usada na interface. |
| icone | string | Não | Ícone usado na interface. |
| created_at | datetime | Sim | Data de criação. |
| updated_at | datetime | Sim | Data da última atualização. |

---

## 5. Requisitos funcionais relacionados

| ID | Título | Descrição curta |
|---|---|---|
| REQ-FUNC-006 | Criar lista de compras | Permitir criação de listas. |
| REQ-FUNC-007 | Editar lista de compras | Permitir alteração de dados da lista. |
| REQ-FUNC-008 | Excluir lista de compras | Permitir remoção de listas. |
| REQ-FUNC-009 | Adicionar item | Permitir inclusão de itens. |
| REQ-FUNC-010 | Editar item | Permitir alteração de itens. |
| REQ-FUNC-011 | Remover item | Permitir exclusão de itens. |
| REQ-FUNC-012 | Marcar item comprado | Controlar status comprado/pendente. |
| REQ-FUNC-013 | Gerenciar categorias | Organizar itens por categoria. |
| REQ-FUNC-014 | Calcular total da lista | Somar valores dos itens. |
| REQ-FUNC-015 | Registrar preço de item | Registrar preço unitário ou total. |
| REQ-FUNC-024 | Fechar compra | Finalizar lista. |
| REQ-FUNC-025 | Gerar resumo da compra | Consolidar informações finais. |
| REQ-FUNC-029 | Compartilhar pelo WhatsApp | Compartilhar lista ou resumo. |

---

## 6. Fluxos principais

### 6.1 Criar lista de compras

1. O usuário acessa a área principal de compras.
2. O usuário seleciona a ação de criar nova lista.
3. O sistema exibe formulário com nome da lista.
4. O usuário informa o nome.
5. O sistema valida o preenchimento obrigatório.
6. O sistema cria a lista com status `ativa`.
7. O sistema exibe a lista criada.

#### Regras aplicáveis

- `RN-COMP-001`: nome da lista é obrigatório.
- `RN-COMP-002`: lista deve pertencer ao usuário autenticado.
- `RN-COMP-003`: nova lista deve iniciar com status `ativa`.

---

### 6.2 Adicionar item

1. O usuário abre uma lista ativa.
2. O usuário seleciona a ação de adicionar item.
3. O sistema exibe formulário de item.
4. O usuário informa nome do item.
5. Opcionalmente, o usuário informa quantidade, unidade, categoria e preço.
6. O sistema valida os dados.
7. O sistema adiciona o item à lista.
8. O sistema recalcula o total da lista.
9. O sistema atualiza a tela.

#### Regras aplicáveis

- `RN-COMP-004`: item deve pertencer a uma lista existente.
- `RN-COMP-005`: nome do item é obrigatório.
- `RN-COMP-006`: item novo deve iniciar como pendente, salvo regra explícita em contrário.

---

### 6.3 Marcar item como comprado

1. O usuário abre uma lista ativa.
2. O usuário visualiza os itens da lista.
3. O usuário marca um item como comprado.
4. O sistema atualiza o estado do item.
5. O sistema recalcula indicadores de progresso.
6. O sistema mantém a alteração persistida.

#### Regras aplicáveis

- `RN-COMP-007`: item comprado deve permanecer associado à lista.
- `RN-COMP-008`: marcar item como comprado não deve remover o item da lista.
- `RN-COMP-009`: o usuário pode desfazer a marcação enquanto a lista estiver ativa.

---

### 6.4 Calcular total da lista

1. O usuário adiciona ou altera preço e quantidade de itens.
2. O sistema identifica itens com valores válidos.
3. O sistema calcula o subtotal de cada item.
4. O sistema soma os subtotais.
5. O sistema exibe o total da lista.

#### Regra de cálculo inicial

Quando `preco_total` estiver preenchido, o sistema pode usar esse valor diretamente. Quando apenas `preco_unitario` e `quantidade` estiverem preenchidos, o sistema deve calcular:

```text
subtotal_item = preco_unitario * quantidade
```

O total da lista deve ser a soma dos subtotais válidos:

```text
total_lista = soma(subtotal_item)
```

Itens sem preço válido não devem impedir o cálculo do restante da lista.

---

### 6.5 Finalizar compra

1. O usuário abre uma lista ativa.
2. O usuário seleciona a ação de finalizar compra.
3. O sistema exibe confirmação.
4. O usuário confirma o fechamento.
5. O sistema calcula o resumo final.
6. O sistema altera o status da lista para `finalizada`.
7. O sistema registra a compra no histórico.
8. O sistema exibe confirmação de fechamento.

#### Regras aplicáveis

- `RN-COMP-010`: somente listas ativas podem ser finalizadas.
- `RN-COMP-011`: lista finalizada não deve ser editada pelo fluxo comum de compras.
- `RN-COMP-012`: lista finalizada deve gerar registro consultável no histórico.

---

## 7. Regras de negócio do módulo

| ID | Regra | Descrição |
|---|---|---|
| RN-COMP-001 | Nome obrigatório da lista | Uma lista não pode ser criada sem nome. |
| RN-COMP-002 | Propriedade da lista | Toda lista deve pertencer a um usuário autenticado. |
| RN-COMP-003 | Status inicial | Toda lista recém-criada deve iniciar como `ativa`. |
| RN-COMP-004 | Item vinculado à lista | Todo item deve pertencer a uma lista existente. |
| RN-COMP-005 | Nome obrigatório do item | Um item não pode ser criado sem nome. |
| RN-COMP-006 | Status inicial do item | Um item novo deve iniciar como pendente. |
| RN-COMP-007 | Marcação de compra | Um item comprado permanece na lista com status alterado. |
| RN-COMP-008 | Desfazer compra | O usuário pode voltar um item comprado para pendente enquanto a lista estiver ativa. |
| RN-COMP-009 | Total parcial | Itens sem preço válido não impedem cálculo dos demais itens. |
| RN-COMP-010 | Quantidade válida | Quantidade, quando informada, deve ser maior que zero. |
| RN-COMP-011 | Preço válido | Preço, quando informado, não pode ser negativo. |
| RN-COMP-012 | Fechamento | Apenas listas ativas podem ser finalizadas. |
| RN-COMP-013 | Histórico | Toda lista finalizada deve gerar registro no histórico. |
| RN-COMP-014 | Permissão | O usuário só pode acessar listas e itens de sua propriedade. |

---

## 8. Estados da lista

| Estado | Descrição | Permite edição? |
|---|---|---:|
| ativa | Lista em uso, editável e visível na área principal. | Sim |
| finalizada | Lista encerrada e registrada no histórico. | Não, exceto fluxo específico futuro. |
| arquivada | Lista mantida para referência, sem destaque. | Não definido nesta versão. |

---

## 9. Estados do item

| Estado | Descrição |
|---|---|
| pendente | Item ainda não comprado. |
| comprado | Item comprado pelo usuário. |

---

## 10. Validações

| Campo | Validação | Mensagem sugerida |
|---|---|---|
| nome da lista | Obrigatório | Informe um nome para a lista. |
| nome do item | Obrigatório | Informe o nome do item. |
| quantidade | Maior que zero, quando informada | A quantidade deve ser maior que zero. |
| preço unitário | Maior ou igual a zero, quando informado | O preço não pode ser negativo. |
| preço total | Maior ou igual a zero, quando informado | O preço total não pode ser negativo. |
| categoria | Deve existir, quando informada | Categoria inválida. |

---

## 11. Telas sugeridas

| Tela | Objetivo | Elementos principais |
|---|---|---|
| Lista de listas | Exibir listas ativas do usuário. | Cards de listas, botão nova lista, busca/filtro futuro. |
| Detalhe da lista | Exibir e gerenciar itens de uma lista. | Itens, total, progresso, ações de item. |
| Formulário de lista | Criar ou editar lista. | Campo nome, salvar, cancelar. |
| Formulário de item | Criar ou editar item. | Nome, quantidade, unidade, categoria, preço. |
| Resumo de fechamento | Confirmar finalização da compra. | Total, itens comprados, pendentes, confirmar. |

---

## 12. Integrações com outros módulos

| Módulo | Integração |
|---|---|
| Autenticação | Identificar usuário dono das listas. |
| Banco de dados | Persistir listas, itens e categorias. |
| Histórico e fechamento | Registrar compra finalizada. |
| Nota fiscal | Importar itens ou associar documento fiscal à compra. |
| Estoque | Atualizar ou sugerir itens de estoque a partir da compra. |
| Notificações | Disparar lembretes relacionados a listas ou itens. |
| Compartilhamento WhatsApp | Enviar lista ou resumo formatado. |

---

## 13. Eventos funcionais sugeridos

| Evento | Quando ocorre | Uso futuro |
|---|---|---|
| shopping_list_created | Lista criada | Analytics, sincronização, auditoria. |
| shopping_list_updated | Lista editada | Sincronização. |
| shopping_list_deleted | Lista excluída | Auditoria. |
| shopping_item_created | Item criado | Sincronização, sugestão futura. |
| shopping_item_checked | Item marcado como comprado | Progresso da compra. |
| shopping_item_unchecked | Item voltou para pendente | Progresso da compra. |
| shopping_list_closed | Compra finalizada | Histórico, resumo, estoque. |
| shopping_list_shared | Lista compartilhada | Analytics e melhoria de UX. |

---

## 14. Critérios de aceite do módulo

- O usuário deve conseguir criar uma lista com nome válido.
- O usuário deve conseguir adicionar itens a uma lista ativa.
- O usuário deve conseguir marcar e desmarcar itens como comprados.
- O sistema deve recalcular o total quando item, quantidade ou preço for alterado.
- O sistema deve impedir valores negativos para preços.
- O sistema deve impedir quantidade menor ou igual a zero quando a quantidade for informada.
- O usuário deve conseguir finalizar uma lista ativa.
- Uma lista finalizada deve ficar disponível no histórico.
- O usuário não deve acessar listas pertencentes a outro usuário.

---

## 15. Pendências para refinamento

- Definir se listas finalizadas poderão ser reabertas.
- Definir se categorias serão globais, por usuário ou mistas.
- Definir se preço total manual tem prioridade sobre preço unitário × quantidade.
- Definir unidades padrão e lista inicial de unidades.
- Definir comportamento offline para criação e edição de listas.
- Definir se exclusão de lista será física ou lógica.
- Definir formato final da mensagem compartilhada no WhatsApp.

---

## 16. Referências relacionadas

- `docs/01-visao-geral/visao-do-produto.md`
- `docs/01-visao-geral/glossario.md`
- `docs/01-visao-geral/requisitos-funcionais.md`
- `docs/03-modulos/historico-e-fechamento.md`
- `docs/03-modulos/nota-fiscal.md`
- `docs/04-banco-de-dados/esquema-er.md`
- `docs/05-contratos-de-api/tabelas-supabase.md`

---

FIM

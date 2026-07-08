# Glossário

- Documento: Glossário do Produto
- Versão: v1.0
- Owners: Equipe de Produto / Engenharia
- Last_update_date: 2026-06-19
- Status: Draft

---

## 1. Objetivo

Este glossário padroniza os principais termos usados na documentação, nos requisitos, no código e nas discussões técnicas do aplicativo `lista_compras`.

O objetivo é evitar ambiguidade, manter consistência entre documentos e facilitar rastreabilidade entre visão do produto, requisitos funcionais, módulos, banco de dados, contratos de API e testes.

---

## 2. Termos do domínio

| Termo | Definição | Exemplo/Observação |
|---|---|---|
| Aplicativo | Produto mobile `lista_compras`, desenvolvido em Flutter. | App usado pelo usuário final. |
| Usuário | Pessoa autenticada ou visitante que interage com o aplicativo. | Usuário cria listas e itens. |
| Conta | Registro associado ao usuário para autenticação e persistência de dados. | Conta com email e senha ou Google. |
| Sessão | Estado em que o usuário permanece autenticado no aplicativo. | Sessão encerrada ao fazer logout. |
| Lista de Compras | Conjunto de itens que o usuário deseja comprar em uma ocasião. | Lista “Mercado da semana”. |
| Item | Produto ou entrada adicionada a uma lista de compras. | Arroz, leite, café. |
| Item comprado | Item marcado pelo usuário como já comprado durante a execução da compra. | Checkbox marcado. |
| Item pendente | Item ainda não marcado como comprado. | Produto que falta comprar. |
| Categoria | Agrupamento usado para organizar itens. | Limpeza, Hortifruti, Bebidas. |
| Quantidade | Valor numérico associado ao item. | 2 unidades, 1 kg, 3 pacotes. |
| Unidade | Medida usada para interpretar a quantidade de um item. | un, kg, g, L, pacote. |
| Preço unitário | Valor monetário de uma unidade do item. | R$ 5,99 por unidade. |
| Preço total do item | Resultado do preço unitário multiplicado pela quantidade, ou valor total informado manualmente. | 2 × R$ 5,99 = R$ 11,98. |
| Total da lista | Soma dos valores dos itens de uma lista. | Total estimado ou realizado. |
| Total estimado | Total calculado antes ou durante a compra com base nos preços informados. | Pode estar incompleto. |
| Total realizado | Total consolidado após a compra ser finalizada. | Valor registrado no histórico. |
| Compra | Execução prática de uma lista de compras. | Ir ao mercado e marcar itens. |
| Compra finalizada | Lista encerrada pelo usuário e enviada para o histórico. | Não deve ser tratada como lista ativa. |
| Histórico | Conjunto de compras finalizadas armazenadas para consulta futura. | Compras anteriores. |
| Resumo da compra | Informações consolidadas de uma compra finalizada. | Total, itens comprados, pendentes. |
| Estoque | Controle básico de produtos que o usuário possui ou deseja acompanhar. | Produtos em casa. |
| Item de estoque | Produto registrado no controle de estoque. | Café com quantidade atual. |
| Validade | Data limite associada a um item de estoque ou produto. | Vence em 2026-08-10. |
| Alerta de estoque | Aviso relacionado a quantidade, validade ou risco de um item de estoque. | Produto vencendo. |
| Snooze | Adiamento temporário de um alerta. | Lembrar novamente amanhã. |
| Nota fiscal | Documento fiscal associado a uma compra. | NFC-e consultada por QR Code. |
| QR Code fiscal | Código presente na nota fiscal usado para acessar dados fiscais. | URL da NFC-e. |
| WebView | Componente usado para exibir página web dentro do aplicativo. | Página da nota fiscal. |
| Parser de nota fiscal | Rotina que tenta extrair dados estruturados de uma nota fiscal. | Itens, valores, quantidade. |
| Compartilhamento | Ação de enviar lista ou resumo para outro aplicativo. | WhatsApp. |
| Deep link | Link que abre uma tela específica do aplicativo. | Abrir uma lista a partir de notificação. |
| Notificação push | Mensagem enviada por serviço remoto para o dispositivo. | FCM. |
| Notificação local | Mensagem agendada e exibida pelo próprio dispositivo. | Lembrete local. |
| Migração de dados | Processo de adaptar dados de versões antigas para a estrutura atual. | Migração v1 para v2. |
| Sincronização | Processo de manter dados locais e remotos consistentes. | Enviar alterações ao backend. |
| Backend | Serviço responsável por autenticação, persistência, regras ou funções remotas. | Supabase ou Firebase. |
| Offline | Estado em que o aplicativo não possui conexão de rede. | Uso parcial sem internet. |
| RLS | Row Level Security; política de segurança por linha no banco de dados. | Usuário acessa apenas seus dados. |

---

## 3. Termos técnicos

| Termo | Definição | Observação |
|---|---|---|
| Flutter | Framework usado para desenvolver o aplicativo mobile. | Base do projeto. |
| Dart | Linguagem de programação usada com Flutter. | Código do app. |
| Supabase | Plataforma backend que pode prover banco, autenticação, storage e políticas RLS. | Decisão final deve estar em ADR. |
| Firebase | Plataforma que pode prover autenticação, notificações, analytics e outros serviços. | Decisão final deve estar em ADR. |
| FCM | Firebase Cloud Messaging, serviço de notificações push. | Usado em notificações remotas. |
| API | Interface de comunicação entre aplicativo e serviços. | Contratos documentados em `docs/05-contratos-de-api/`. |
| CRUD | Operações de criar, ler, atualizar e excluir. | Create, Read, Update, Delete. |
| Model | Estrutura de dados usada no app para representar entidades. | Ex.: modelo de Item. |
| Service | Camada responsável por regras de integração e acesso a dados. | Ex.: serviço de compras. |
| Repository | Camada que abstrai origem de dados. | Local ou remoto. |
| Widget | Componente de interface do Flutter. | Tela, botão, card. |
| Screen | Tela completa do aplicativo. | Tela de lista de compras. |
| State | Estado interno de uma tela ou funcionalidade. | Lista carregada, erro, loading. |
| setState | Mecanismo básico do Flutter para atualizar estado local. | Pode evoluir para outro gerenciador. |
| StreamBuilder | Widget que reconstrói UI a partir de streams. | Útil com dados em tempo real. |
| SnackBar | Mensagem temporária exibida ao usuário. | Feedback de sucesso ou erro. |
| ADR | Architecture Decision Record; documento de decisão arquitetural. | `docs/08-adr/`. |
| CI/CD | Processo automatizado de integração, build, teste e entrega. | GitHub Actions. |
| APK | Pacote Android gerado pelo build. | Distribuição Android. |
| IPA | Pacote iOS gerado pelo build. | Distribuição iOS. |

---

## 4. Entidades principais

| Entidade | Descrição | Possíveis atributos |
|---|---|---|
| User | Representa o usuário autenticado. | id, nome, email, provider. |
| ShoppingList | Representa uma lista de compras. | id, user_id, nome, status, total, created_at. |
| ShoppingItem | Representa um item de uma lista. | id, list_id, nome, quantidade, preço, comprado. |
| Category | Representa uma categoria de itens. | id, user_id, nome, cor/ícone. |
| PurchaseHistory | Representa uma compra finalizada. | id, list_id, total_final, data_fechamento. |
| StockItem | Representa item no estoque. | id, user_id, nome, quantidade_atual, validade. |
| Notification | Representa uma notificação ou agendamento. | id, user_id, tipo, payload, status. |
| FiscalDocument | Representa dados de nota fiscal. | id, user_id, url, chave, status_parse. |

---

## 5. Estados e status

| Status | Aplicável a | Significado |
|---|---|---|
| ativa | Lista de compras | Lista em uso e editável. |
| finalizada | Lista de compras | Lista encerrada e registrada no histórico. |
| arquivada | Lista de compras | Lista antiga mantida sem destaque. |
| comprado | Item | Item marcado como comprado. |
| pendente | Item | Item ainda não comprado. |
| vencido | Item de estoque | Produto com validade ultrapassada. |
| próximo_vencimento | Item de estoque | Produto com validade próxima. |
| normal | Item de estoque | Produto sem alerta relevante. |
| enviado | Notificação | Notificação enviada com sucesso. |
| agendado | Notificação | Notificação aguardando envio/exibição. |
| falhou | Notificação ou operação | Operação não concluída. |

---

## 6. Convenções de nomenclatura

| Tipo | Convenção | Exemplo |
|---|---|---|
| Requisito funcional | `REQ-FUNC-XXX` | `REQ-FUNC-006` |
| Regra de negócio | `RN-XXX` | `RN-001` |
| Caso de uso | `UC-MOD-XXX` | `UC-COMP-001` |
| Caso de teste | `TC-REQ-FUNC-XXX` | `TC-REQ-FUNC-006` |
| ADR | `adr-XXX-descricao.md` | `adr-001-supabase-vs-firebase.md` |
| Tabela de banco | snake_case plural | `shopping_lists` |
| Campo de banco | snake_case | `created_at` |
| Classe Dart | PascalCase | `ShoppingList` |
| Variável Dart | camelCase | `shoppingListId` |
| Arquivo Dart | snake_case | `shopping_list_service.dart` |

---

## 7. Termos a evitar

| Termo ambíguo | Preferir | Motivo |
|---|---|---|
| Produto | Item | “Produto” pode significar o app ou item de compra. |
| Marcado | Item comprado | Mais específico. |
| Compra antiga | Compra finalizada ou histórico | Melhora rastreabilidade. |
| Valor | Preço ou total | Evita confusão entre preço unitário e total. |
| Link | URL ou deep link | Diferencia link externo de link interno do app. |

---

## 8. Referências relacionadas

- `docs/01-visao-geral/visao-do-produto.md`
- `docs/01-visao-geral/requisitos-funcionais.md`
- `docs/03-modulos/compras.md`
- `docs/04-banco-de-dados/esquema-er.md`
- `docs/05-contratos-de-api/tabelas-supabase.md`

---

FIM

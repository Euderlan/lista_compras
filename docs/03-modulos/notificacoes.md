# Notificações — Documentação Técnica (v1.0)

## Metadados
- **Projeto**: `lista_compras`
- **Data de geração**: 2026-08-26
- **Status**: `v1.0-draft`
- **Responsável técnico**: `Arquiteto‑Chefe de Documentação`
- **Persona‑Version**: `persona‑08`
- **Prompt usado**: `docs/prompts/prompt-01-notificacoes.md`
- **Evidence‑Map‑Output**: `docs/prompts/matriz-rastreabilidade.md`

## Visão Geral
O módulo **Notificações** tem como objetivo alertar o usuário sobre produtos que estão acabando, enviar notificações push quando o app está fechado e exibir diálogos de confirmação ao abrir o app.

## Arquitetura de Alto Nível
- **Mobile App (Flutter)** → **NotificationService** (FCM + FlutterLocalNotifications)
- **Supabase** (`device_tokens`): persiste tokens de dispositivos.
- **NotificacaoEstoqueService**: lógica de UI de estoque (diálogos).
- **MainNavigationWrapper**: orquestra a chamada ao serviço de notificação de estoque.

## Fluxo de Dados Detalhado
1. `main()` → `NotificationService.inicializar()` cria canal Android e solicita permissão (arquivo `lib/services/notification_service.dart`, linhas 22‑85).  
2. `NotificationService.salvarToken()` grava token FCM no Supabase (`device_tokens`) (linhas 87‑115).  
3. `MainNavigationWrapper.initState()` chama `NotificationService.salvarToken()` (linha 135) e agenda `_verificarEstoques()` logo após a primeira renderização.  
4. `_verificarEstoques()` → `NotificacaoEstoqueService.verificarENotificar()` (arquivo `lib/services/notificacao_estoque_service.dart`, linhas 13‑33).  
5. `verificarENotificar` consulta produtos a notificar via `ProdutoEstoqueService` e exibe diálogos sequenciais (`_mostrarDialogo`, linhas 36‑72).  
6. Cada ação do diálogo (`Acabou`, `Ainda não`, `Em 3 dias`) dispara lógica de atualização de estoque e/ou cria `ProdutoAcabando`.  
7. `_calcularDiasSnooze` calcula dinamicamente o período de snooze baseado em peso/quantidade (linhas 74‑83).

## Modelo de Dados
| Classe / Tabela | Campos Principais | Descrição |
|-----------------|-------------------|-----------|
| `NotificationService` | `_messaging`, `_localNotifications`, `_supabase` | Instâncias de FCM, plugin de notificações locais e cliente Supabase. |
| `device_tokens` (Supabase) | `usuario_id`, `token`, `atualizado_em` | Mapeia usuários ao token FCM. |
| `ProdutoEstoque` | `id`, `usuarioId`, `nome`, `quantidade`, `unidade`, `pesoUnitario`, `mesAno` | Representa produtos armazenados no estoque. |
| `ProdutoAcabando` | `id`, `nome`, `categoria`, `dataMarcado` | Item que será incluído em Compras Futuras. |
| `Compra` | `id`, `nome`, `preco`, `quantidade`, `categoria`, `loja`, `data` | Compra extraída de nota fiscal. |

## Integrações
- **Firebase Cloud Messaging** – entrega de push notifications.
- **Flutter Local Notifications** – exibição de notificações quando o app está em foreground.
- **Supabase** – persiste tokens de dispositivos (`device_tokens`).
- **MainNavigationWrapper** – orquestra a chamada ao serviço de notificação de estoque.

## Segurança e Privacidade
- Tokens FCM são armazenados apenas no backend Supabase, associados ao `usuario_id` autenticado.
- Nenhum dado sensível (ex.: informações de compra) é incluído nas push notifications; apenas mensagens genéricas (`"Produtos acabando"`).
- `NotificationService.salvarToken` verifica existência de usuário antes de gravar.
- O canal Android é configurado com prioridade `high` para garantir entrega.

## Testes
- **Teste unitário** para `_calcularDiasSnooze` (valida retorno conforme peso total) – **PENDING: User Input** (não há teste implementado).
- **Teste de UI** para `_DialogoEstoque` – **PENDING**.
- **Teste de integração** para `NotificationService.inicializar` – **PENDING**.
- **Teste de contrato** para Supabase `device_tokens` (upsert e delete) – **PENDING**.

## Restrições e Regras de Negócio
- **Regra 1** – Nunca enviar notificações que contenham dados pessoais do usuário.
- **Regra 2** – O token deve ser removido ao fazer logout (`NotificationService.removerToken`).
- **Regra 3** – Diálogos de estoque só são exibidos quando o app está em foreground e o contexto está montado.
- **Regra 4** – Se o usuário selecionar "Ainda não acabou", o snooze é calculado dinamicamente com base no peso total (ver seção Fluxo de Dados).
- **Regra 5** – Nenhuma lógica de notificação deve ser executada antes da permissão ser concedida.

## Referências
- `lib/services/notification_service.dart`
- `lib/services/notificacao_estoque_service.dart`
- `lib/main.dart`
- `lib/models/produto_estoque.dart`
- `lib/models/produto_acabando.dart`
- `lib/models/compra.dart`

## Mapa de Rastreabilidade de Implementação
| ID | Requisito | Implementação (arquivo:classe:método linhas) | Evidência (arquivo + linhas) | Teste |
|----|-----------|----------------------------------------------|-----------------------------|-------|
| REQ‑NOT‑001 | Inicialização das notificações push via FCM e canal Android | `lib/services/notification_service.dart:NotificationService.inicializar 22‑85` | `lib/services/notification_service.dart` linhas 22‑85 | PENDING |
| REQ‑NOT‑002 | Persistência de token FCM no Supabase | `lib/services/notification_service.dart:NotificationService.salvarToken 87‑115` | `lib/services/notification_service.dart` linhas 87‑115 | PENDING |
| REQ‑NOT‑003 | Exibição de notificações de estoque via diálogos | `lib/services/notificacao_estoque_service.dart:NotificacaoEstoqueService.verificarENotificar 13‑33`<br>`lib/services/notificacao_estoque_service.dart:_mostrarDialogo 36‑72` | `lib/services/notificacao_estoque_service.dart` linhas 13‑33 e 36‑72 | PENDING |
| REQ‑NOT‑004 | Cálculo dinâmico de snooze baseado em peso/quantidade | `lib/services/notificacao_estoque_service.dart:_calcularDiasSnooze 74‑83` | `lib/services/notificacao_estoque_service.dart` linhas 74‑83 | PENDING |
| REQ‑NOT‑005 | Integração de verificação de estoque ao iniciar a UI | `lib/main.dart:MainNavigationWrapper._verificarEstoques 141‑148` (chama `NotificacaoEstoqueService.verificarENotificar`) | `lib/main.dart` linhas 141‑148 | PENDING |
| REQ‑NOT‑006 | Remoção de token ao logout | `lib/services/notification_service.dart:NotificationService.removerToken 119‑136`<br>`lib/main.dart:MainNavigationWrapper._logout 436‑438` | `lib/services/notification_service.dart` linhas 119‑136 | PENDING |

> **Mapa de Evidências completo** gerado em `docs/prompts/matriz-rastreabilidade.md`.

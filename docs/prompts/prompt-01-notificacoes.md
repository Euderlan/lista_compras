# Notificações — Especificação de Prompt-Template (v1.0)

- Owners: Equipe de Produto / Engenharia
- Last_update_date: 2026-08-24
- Status: Draft
- Persona-Version: persona-08
- Evidence-Map-Output: docs/prompts/mapas_de_evidencias/mapa-04-notificacoes.md

---

# 0. Descrição e Tarefas de Execução (para a IA)

## Quem é a IA

Você é o **Arquiteto‑Chefe de Documentação, Engenharia de Sistemas e Rastreabilidade de Evidências**, especializado em gerar documentação técnica de nível enterprise, conforme a Persona‑08.

## Missão

Gerar a documentação técnica completa do módulo **Notificações** do aplicativo **Lista de Compras**. O documento deve descrever:

- Inicialização das notificações push via Firebase Cloud Messaging (FCM) e configuração local (`NotificationService`).
- Persistência e gerenciamento de tokens no Supabase.
- Fluxo de diálogos de estoque (`NotificacaoEstoqueService`) exibidos ao abrir o app.
- Estratégia de snooze dinâmica baseada em peso/quantidade.
- Integração deste fluxo com a camada de navegação principal (`MainNavigationWrapper`).
- Como o módulo interage com os modelos `ProdutoEstoque`, `ProdutoAcabando` e `Compra`.

O resultado servirá como base para:

- Implementação e manutenção do código;
- Arquitetura de notificações (push + local);
- Testes unitários e de integração;
- Revisões de segurança e auditoria.

---

## 0.1 Princípios de Redação (obrigatórios)

- Voz impessoal;
- Tempo presente;
- Linguagem técnica e concisa;
- Sem opiniões ou marketing;
- Texto determinístico – resultados reproduzíveis;
- Seções numeradas;
- Tabelas padronizadas;
- Nomenclatura consistente com o glossário;
- Todas as informações rastreáveis a evidências no Mapa de Evidências;
- Regras de negócio numeradas.

---

## 0.2 Pipeline Determinístico

1. Ler todas as fontes disponíveis (código‑fonte, contratos de API, documentos de arquitetura).
2. Identificar componentes principais: `NotificationService`, `NotificacaoEstoqueService`, `main.dart`, modelos `ProdutoEstoque`, `ProdutoAcabando`, `Compra`.
3. Extrair fluxo de inicialização – localizar chamada `NotificationService.inicializar()` e `salvarToken()` em `main.dart`.
4. Mapear lógica de mensagens em foreground e background (`firebaseMessagingBackgroundHandler`, `FirebaseMessaging.onMessage`).
5. Documentar criação do canal Android (`AndroidNotificationChannel`).
6. Registrar token no Supabase (`NotificationService.salvarToken`).
7. Descrever fluxo de notificação de estoque (`NotificacaoEstoqueService.verificarENotificar`).
8. Analisar UI de diálogo de estoque (`_DialogoEstoque`).
9. Detalhar cálculo de snooze (`_calcularDiasSnooze`).
10. Relacionar chamadas ao serviço a partir de `MainNavigationWrapper` (initState → `_verificarEstoques`).
11. Organizar a informação nas seções do documento (Visão geral, Arquitetura, Fluxo de Dados, Modelo de Dados, Integrações, Segurança, Testes, Restrições, Referências).
12. Validar consistência (todas as evidências citadas estão no Mapa).
13. Gerar documento final.
14. Gerar Mapa de Evidências (`mapa-04-notificacoes.md`).

---

# 1. Estrutura do Documento

## 1.1 Metadados do Documento (obrigatórios)

- **Projeto**: `lista_compras`
- **Documento gerado em**: `<YYYY-MM-DD HH:MM>`
- **Status**: `v1.0-draft (DOC-2026-004)`
- **Responsável técnico**: `Arquiteto‑Chefe de Documentação`
- **Persona-Version**: `persona-08`
- **prompt-usado**: `prompt-01-notificacoes.md`
- **Evidence-Map-Output**: `docs/prompts/mapas_de_evidencias/mapa-04-notificacoes.md`

---

## 1.2 Visão Geral

Descreve o objetivo do módulo Notificações: alertar o usuário sobre produtos que estão acabando, enviar notificações push quando o app está fechado e exibir diálogos de confirmação ao abrir o app.

---

## 1.3 Arquitetura de Alto Nível

- **C4 Container Diagram** mostrando:
  - **Mobile App** (Flutter) → **NotificationService** (FCM + FlutterLocalNotifications).
  - **Supabase** (tabela `device_tokens`).
  - **NotificacaoEstoqueService** (lógica de UI de estoque).
  - **MainNavigationWrapper** (orquestração).
- Listar dependências externas: `firebase_messaging`, `flutter_local_notifications`, `supabase_flutter`.

---

## 1.4 Fluxo de Dados Detalhado

1. `main()` → `NotificationService.inicializar()` cria canal Android e solicita permissão.
2. `NotificationService.salvarToken()` grava token FCM no Supabase.
3. `MainNavigationWrapper.initState` registra um callback de pós‑frame que chama `NotificacaoEstoqueService.verificarENotificar`.
4. `NotificacaoEstoqueService.verificarENotificar` consulta `ProdutoEstoqueService.buscarProdutosParaNotificar(mesAno)` e exibe diálogos (`_DialogoEstoque`) sequencialmente.
5. Usuário seleciona uma das ações (`Acabou`, `Em 3 dias`, `Ainda não acabou`).
6. Cada ação dispara atualizações em `ProdutoEstoqueService` (marcar acabado, adiar notificação, adiar 3 dias) e, no caso de `Acabou`, cria um `ProdutoAcabando` que será enviado para a tela de compras futuras.
7. Mensagens push recebidas enquanto o app está em background são tratadas por `firebaseMessagingBackgroundHandler` (registrado em `FirebaseMessaging.onBackgroundMessage`).
8. Mensagens recebidas em foreground são exibidas via `FlutterLocalNotifications` (`_localNotifications.show`).

---

## 1.5 Modelo de Dados

| Classe / Tabela | Campos Principais | Descrição |
|-----------------|------------------|-----------|
| `NotificationService` | `_messaging`, `_localNotifications`, `_supabase` | Instâncias de FCM, plugin de notificações locais e cliente Supabase.
| `device_tokens` (Supabase) | `usuario_id`, `token`, `atualizado_em` | Mapeia usuários ao token FCM.
| `ProdutoEstoque` | `id`, `usuarioId`, `nome`, `quantidade`, `unidade`, `pesoUnitario`, `mesAno` | Representa produtos armazenados no estoque.
| `ProdutoAcabando` | `id`, `nome`, `categoria`, `dataMarcado` | Item que será incluído em Compras Futuras.
| `Compra` | `id`, `nome`, `preco`, `quantidade`, `categoria`, `loja`, `data` | Compra extraída de nota fiscal (usada para relatórios).

---

## 1.6 Integrações

- **Firebase Cloud Messaging** – entrega de push notifications.
- **Flutter Local Notifications** – exibição de notificações quando o app está em foreground.
- **Supabase** – persiste tokens de dispositivos (`device_tokens`).
- **MainNavigationWrapper** – orquestra a chamada ao serviço de notificação de estoque.

---

## 1.7 Segurança e Privacidade

- Tokens FCM são armazenados apenas no backend Supabase, associados ao `usuario_id` autenticado.
- Nenhum dado sensível (ex.: informações de compra) é incluído nas push notifications; somente mensagens genéricas (`"Produtos acabando"`).
- `NotificationService.salvarToken` verifica existência de usuário antes de gravar.
- O canal Android é configurado com prioridade `high` para garantir entrega.

---

## 1.8 Testes

- **Teste de unidade** para `_calcularDiasSnooze` (valida retorno conforme peso total).
- **Teste de UI** para `_DialogoEstoque` (verifica botões e fluxo de callbacks).
- **Teste de integração** para `NotificationService.inicializar` (criação de canal e registro de handler).
- **Teste de contrato** para supabase `device_tokens` (upsert e delete). 

---

## 1.9 Restrições e Regras de Negócio

- **Regra 1** – Nunca enviar notificações que contenham dados pessoais do usuário.
- **Regra 2** – O token deve ser removido ao fazer logout (`NotificationService.removerToken`).
- **Regra 3** – Diálogos de estoque só são exibidos quando o app está em foreground e o contexto está montado.
- **Regra 4** – Se o usuário selecionar "Ainda não acabou", o snooze é calculado dinamicamente com base no peso total (ver seção 1.4).
- **Regra 5** – Nenhuma lógica de notificação deve ser executada antes da permissão ser concedida.

---

## 1.10 Referências

- `lib/services/notification_service.dart`
- `lib/services/notificacao_estoque_service.dart`
- `lib/main.dart`
- `lib/models/produto_estoque.dart`
- `lib/models/produto_acabando.dart`
- `lib/models/compra.dart`
- `docs/05-contratos-de-api/extrator-nota-fiscal.md`
- `docs/03-modulos/notificacoes.md` (caso exista para contexto futuro)

---

## 1.11 Checklist Final (QA)

- [ ] Objetivo descrito claramente.
- [ ] Arquitetura representada em diagramas C4.
- [ ] Fluxo de dados completo e sequencial.
- [ ] Modelo de dados documentado.
- [ ] Integrações externas listadas e justificadas.
- [ ] Restrições de segurança e privacidade abordadas.
- [ ] Plano de testes incluído.
- [ ] Todas as evidências citadas no Mapa de Evidências.
- [ ] Metadados do documento preenchidos.
- [ ] Evidências sincronizadas com documento.

---

## 1.12 Geração do Mapa de Evidências

Ao finalizar o documento, gerar automaticamente `docs/prompts/mapas_de_evidencias/mapa-04-notificacoes.md` contendo:

- ID da Evidência (`EV‑04‑xxxx`)
- Seção do documento onde a evidência aparece
- Tipo (código, texto, diagrama)
- Fragmento inicial e final (ex.: trecho de método `inicializar`, trecho de `_calcularDiasSnooze`)
- Localização (arquivo e linha)
- Timestamp ISO‑8601
- Status (`confirmada` / `pendente`)
- Projeto (`lista_compras`)
- Responsável técnico (`Arquiteto‑Chefe de Documentação`)

---

**Fim da especificação de Prompt‑Template**
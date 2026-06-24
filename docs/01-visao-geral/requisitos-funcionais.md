# Requisitos Funcionais

- Documento: Requisitos Funcionais
- Versão: v1.0
- Generated_by: GPT-5.5 Thinking — IA Engenheira de Requisitos
- Generated_on: 2026-06-23
- Owners: Equipe de Produto / Engenharia de Requisitos
- Last_update_date: 2026-06-23
- Status: Draft

---

## Sumário Executivo

Este documento consolida os requisitos funcionais iniciais do aplicativo `lista_compras`, um aplicativo Flutter voltado ao controle de compras, categorias, totais, nota fiscal, estoque, histórico, notificações e compartilhamento. Os requisitos foram extraídos do contexto de documentação planejado para o repositório e organizados para rastreabilidade, priorização MoSCoW e futura associação com casos de teste.

## Glossário (referência)

- Glossário ainda não fornecido.
- Referência futura sugerida: `docs/01-visao-geral/glossario.md`.

---

## Lista de Requisitos Funcionais

| ID | Título | Enunciado | Actor | Prioridade | Critérios de Aceite | Fonte | Tags | Provenance |
|---|---|---|---|---|---|---|---|---|
| REQ-FUNC-001 | Cadastro por email | O sistema deverá permitir que o usuário crie uma conta usando email e senha. | Usuário | Must | 1) Permitir informar nome, email e senha; 2) Validar formato do email; 3) Rejeitar cadastro com email já existente; 4) Criar a conta quando os dados forem válidos. | user_context: módulos/autenticacao | auth, cadastro, usuário | trace=REQFUNC-001; source=user_prompt; module=autenticacao |
| REQ-FUNC-002 | Login por email | O sistema deverá permitir que o usuário autentique-se usando email e senha. | Usuário | Must | 1) Permitir informar email e senha; 2) Validar credenciais; 3) Direcionar usuário autenticado para a área principal; 4) Exibir mensagem de erro para credenciais inválidas. | user_context: módulos/autenticacao | auth, login, sessão | trace=REQFUNC-002; source=user_prompt; module=autenticacao |
| REQ-FUNC-003 | Login com Google | O sistema deverá permitir que o usuário autentique-se usando uma conta Google. | Usuário | Should | 1) Exibir opção de login com Google; 2) Solicitar autorização da conta Google; 3) Criar ou vincular usuário autenticado; 4) Direcionar para a área principal após sucesso. | user_context: módulos/autenticacao | auth, google, sessão | trace=REQFUNC-003; source=user_prompt; module=autenticacao |
| REQ-FUNC-004 | Recuperação de senha | O sistema deverá permitir que o usuário solicite recuperação de senha por email. | Usuário | Must | 1) Permitir informar email cadastrado; 2) Enviar instruções de recuperação; 3) Exibir confirmação de solicitação; 4) Não revelar se o email pertence a outro usuário quando aplicável. | user_context: módulos/autenticacao | auth, senha, recuperação | trace=REQFUNC-004; source=user_prompt; module=autenticacao |
| REQ-FUNC-005 | Encerrar sessão | O sistema deverá permitir que o usuário encerre sua sessão autenticada. | Usuário | Must | 1) Exibir ação de sair; 2) Encerrar sessão local e remota quando aplicável; 3) Redirecionar para tela de autenticação; 4) Impedir acesso às telas protegidas após logout. | user_context: módulos/autenticacao | auth, logout, sessão | trace=REQFUNC-005; source=user_prompt; module=autenticacao |
| REQ-FUNC-006 | Criar lista de compras | O sistema deverá permitir que o usuário crie uma lista de compras. | Usuário | Must | 1) Permitir informar nome da lista; 2) Criar lista associada ao usuário autenticado; 3) Exibir a lista criada na tela principal; 4) Validar nome obrigatório. | user_context: módulos/compras | compras, lista, criação | trace=REQFUNC-006; source=user_prompt; module=compras |
| REQ-FUNC-007 | Editar lista de compras | O sistema deverá permitir que o usuário edite informações de uma lista de compras existente. | Usuário | Must | 1) Permitir alterar nome da lista; 2) Salvar alterações; 3) Refletir alterações na listagem; 4) Impedir edição de listas sem permissão. | user_context: módulos/compras | compras, lista, edição | trace=REQFUNC-007; source=user_prompt; module=compras |
| REQ-FUNC-008 | Excluir lista de compras | O sistema deverá permitir que o usuário exclua uma lista de compras. | Usuário | Must | 1) Solicitar confirmação antes da exclusão; 2) Remover a lista da listagem; 3) Remover ou desvincular itens associados conforme regra definida; 4) Impedir exclusão de listas sem permissão. | user_context: módulos/compras | compras, lista, exclusão | trace=REQFUNC-008; source=user_prompt; module=compras |
| REQ-FUNC-009 | Adicionar item | O sistema deverá permitir que o usuário adicione itens a uma lista de compras. | Usuário | Must | 1) Permitir informar nome do item; 2) Permitir informar quantidade quando aplicável; 3) Associar item à lista selecionada; 4) Exibir item na lista após salvar. | user_context: módulos/compras | compras, item, criação | trace=REQFUNC-009; source=user_prompt; module=compras |
| REQ-FUNC-010 | Editar item | O sistema deverá permitir que o usuário edite itens de uma lista de compras. | Usuário | Must | 1) Permitir alterar nome, quantidade e categoria quando disponíveis; 2) Salvar alterações; 3) Atualizar a lista em tela; 4) Impedir edição de itens sem permissão. | user_context: módulos/compras | compras, item, edição | trace=REQFUNC-010; source=user_prompt; module=compras |
| REQ-FUNC-011 | Remover item | O sistema deverá permitir que o usuário remova itens de uma lista de compras. | Usuário | Must | 1) Disponibilizar ação de remoção por item; 2) Solicitar confirmação quando aplicável; 3) Remover item da lista; 4) Atualizar totais relacionados após remoção. | user_context: módulos/compras | compras, item, exclusão | trace=REQFUNC-011; source=user_prompt; module=compras |
| REQ-FUNC-012 | Marcar item comprado | O sistema deverá permitir que o usuário marque um item como comprado. | Usuário | Must | 1) Exibir estado comprado/não comprado por item; 2) Permitir alternar o estado; 3) Persistir alteração; 4) Atualizar indicadores da lista após a alteração. | user_context: módulos/compras | compras, item, status | trace=REQFUNC-012; source=user_prompt; module=compras |
| REQ-FUNC-013 | Gerenciar categorias | O sistema deverá permitir que o usuário gerencie categorias de itens. | Usuário | Should | 1) Permitir criar categoria; 2) Permitir editar categoria; 3) Permitir excluir categoria não utilizada ou tratar vínculo existente; 4) Permitir associar categoria a itens. | user_context: módulos/compras | categorias, item, organização | trace=REQFUNC-013; source=user_prompt; module=compras |
| REQ-FUNC-014 | Calcular total da lista | O sistema deverá calcular o total estimado ou realizado da lista de compras com base nos itens que possuem preço informado. | Sistema | Must | 1) Somar preço e quantidade dos itens; 2) Atualizar total ao criar, editar, remover ou marcar item; 3) Exibir total na lista; 4) Ignorar ou tratar itens sem preço conforme regra definida. | user_context: módulos/compras | compras, totais, cálculo | trace=REQFUNC-014; source=user_prompt; module=compras |
| REQ-FUNC-015 | Registrar preço de item | O sistema deverá permitir que o usuário registre preço unitário ou total para itens de compra. | Usuário | Should | 1) Permitir informar valor monetário válido; 2) Associar preço ao item; 3) Usar preço no cálculo do total; 4) Validar valores negativos ou inválidos. | user_context: módulos/compras | compras, preço, totais | trace=REQFUNC-015; source=user_prompt; module=compras |
| REQ-FUNC-016 | Ler QR Code fiscal | O sistema deverá permitir que o usuário leia QR Code de nota fiscal para iniciar a importação de dados. | Usuário | Should | 1) Abrir leitor de QR Code; 2) Capturar URL ou chave da nota fiscal; 3) Validar conteúdo lido; 4) Informar erro quando o QR Code não for reconhecido. | user_context: módulos/nota-fiscal | nota-fiscal, qr-code, importação | trace=REQFUNC-016; source=user_prompt; module=nota-fiscal |
| REQ-FUNC-017 | Abrir nota fiscal | O sistema deverá permitir que o usuário visualize a nota fiscal em WebView quando houver URL fiscal válida. | Usuário | Could | 1) Abrir WebView com a URL da nota; 2) Manter navegação dentro do app; 3) Exibir carregamento durante abertura; 4) Exibir erro quando a página não puder ser carregada. | user_context: módulos/nota-fiscal | nota-fiscal, webview, visualização | trace=REQFUNC-017; source=user_prompt; module=nota-fiscal |
| REQ-FUNC-018 | Importar itens fiscais | O sistema deverá extrair itens de uma nota fiscal quando os dados estiverem disponíveis para leitura. | Sistema | Could | 1) Identificar itens da nota fiscal; 2) Extrair nome, quantidade e valor quando disponíveis; 3) Permitir revisão antes de inserir na lista; 4) Informar quando a extração não for possível. | user_context: módulos/nota-fiscal | nota-fiscal, parser, importação | trace=REQFUNC-018; source=user_prompt; module=nota-fiscal |
| REQ-FUNC-019 | Controlar estoque | O sistema deverá permitir que o usuário registre itens de estoque associados às compras. | Usuário | Should | 1) Permitir cadastrar item em estoque; 2) Permitir informar quantidade atual; 3) Permitir atualizar quantidade; 4) Exibir itens cadastrados no controle de estoque. | user_context: módulos/controle-de-estoque | estoque, cadastro, quantidade | trace=REQFUNC-019; source=user_prompt; module=controle-estoque |
| REQ-FUNC-020 | Rastrear validade | O sistema deverá permitir que o usuário registre data de validade para itens de estoque. | Usuário | Should | 1) Permitir informar data de validade; 2) Associar validade ao item; 3) Exibir itens com validade próxima; 4) Validar datas inválidas. | user_context: módulos/controle-de-estoque | estoque, validade, rastreamento | trace=REQFUNC-020; source=user_prompt; module=controle-estoque |
| REQ-FUNC-021 | Classificar risco de estoque | O sistema deverá calcular ou exibir uma classificação de risco para itens de estoque com base em validade, quantidade ou regra definida. | Sistema | Could | 1) Definir status de risco para item; 2) Atualizar status quando quantidade ou validade mudar; 3) Exibir status ao usuário; 4) Permitir identificar itens críticos. | user_context: módulos/controle-de-estoque | estoque, risco, score | trace=REQFUNC-021; source=user_prompt; module=controle-estoque |
| REQ-FUNC-022 | Adiar alerta de estoque | O sistema deverá permitir que o usuário adie temporariamente alertas relacionados a itens de estoque. | Usuário | Could | 1) Exibir opção de adiar alerta; 2) Registrar período de adiamento; 3) Ocultar alerta durante o período definido; 4) Reativar alerta após o período. | user_context: módulos/controle-de-estoque | estoque, alerta, snooze | trace=REQFUNC-022; source=user_prompt; module=controle-estoque |
| REQ-FUNC-023 | Manter histórico | O sistema deverá manter histórico das listas de compras concluídas ou fechadas. | Sistema | Must | 1) Registrar lista concluída no histórico; 2) Preservar itens e totais associados; 3) Exibir histórico ao usuário; 4) Permitir consultar detalhes de uma compra histórica. | user_context: módulos/historico-e-fechamento | histórico, fechamento, compras | trace=REQFUNC-023; source=user_prompt; module=historico-fechamento |
| REQ-FUNC-024 | Fechar compra | O sistema deverá permitir que o usuário finalize uma lista de compras. | Usuário | Must | 1) Disponibilizar ação de fechamento; 2) Confirmar fechamento antes de concluir; 3) Marcar lista como finalizada; 4) Enviar lista finalizada para histórico. | user_context: módulos/historico-e-fechamento | fechamento, compras, histórico | trace=REQFUNC-024; source=user_prompt; module=historico-fechamento |
| REQ-FUNC-025 | Gerar resumo da compra | O sistema deverá gerar resumo da compra ao finalizar uma lista. | Sistema | Should | 1) Exibir total da compra; 2) Exibir quantidade de itens comprados; 3) Exibir itens pendentes quando existirem; 4) Registrar resumo no histórico. | user_context: módulos/historico-e-fechamento | resumo, fechamento, totais | trace=REQFUNC-025; source=user_prompt; module=historico-fechamento |
| REQ-FUNC-026 | Enviar notificações push | O sistema deverá enviar notificações push para eventos relevantes do aplicativo. | Sistema | Should | 1) Solicitar permissão de notificação; 2) Registrar token de notificação; 3) Enviar notificação para evento configurado; 4) Abrir destino correto ao tocar na notificação. | user_context: módulos/notificacoes | notificações, push, fcm | trace=REQFUNC-026; source=user_prompt; module=notificacoes |
| REQ-FUNC-027 | Enviar notificações locais | O sistema deverá exibir notificações locais para lembretes configurados no dispositivo. | Sistema | Could | 1) Agendar notificação local; 2) Exibir notificação no horário previsto; 3) Cancelar notificação quando não for mais aplicável; 4) Abrir tela relacionada ao tocar na notificação. | user_context: módulos/notificacoes | notificações, local, lembrete | trace=REQFUNC-027; source=user_prompt; module=notificacoes |
| REQ-FUNC-028 | Abrir deep link | O sistema deverá tratar deep links de notificações ou compartilhamentos para abrir a tela correspondente. | Sistema | Should | 1) Reconhecer deep link válido; 2) Direcionar para tela de lista, item ou histórico quando aplicável; 3) Tratar deep link inválido com mensagem adequada; 4) Exigir autenticação antes de abrir conteúdo protegido. | user_context: módulos/notificacoes | deep-link, navegação, notificações | trace=REQFUNC-028; source=user_prompt; module=notificacoes |
| REQ-FUNC-029 | Compartilhar pelo WhatsApp | O sistema deverá permitir que o usuário compartilhe lista ou resumo de compra pelo WhatsApp. | Usuário | Should | 1) Gerar mensagem formatada da lista ou resumo; 2) Abrir WhatsApp ou seletor compatível; 3) Preservar itens e totais na mensagem; 4) Informar quando o compartilhamento não puder ser iniciado. | user_context: módulos/compartilhamento-whatsapp | whatsapp, compartilhamento, url-launcher | trace=REQFUNC-029; source=user_prompt; module=compartilhamento-whatsapp |
| REQ-FUNC-030 | Compartilhar URL | O sistema deverá permitir que o usuário gere ou abra URL de compartilhamento quando o recurso estiver disponível. | Usuário | Could | 1) Gerar URL associada ao conteúdo compartilhável; 2) Abrir URL usando mecanismo do dispositivo; 3) Validar permissão de acesso ao conteúdo; 4) Informar falha de abertura ou geração. | user_context: módulos/compartilhamento-whatsapp | compartilhamento, url, navegação | trace=REQFUNC-030; source=user_prompt; module=compartilhamento-whatsapp |
| REQ-FUNC-031 | Migrar dados antigos | O sistema deverá migrar dados de versões anteriores para o modelo de dados atual quando necessário. | Sistema | Should | 1) Detectar versão antiga de dados; 2) Executar migração definida; 3) Preservar dados existentes; 4) Registrar falhas de migração para diagnóstico. | user_context: módulos/migracao-de-dados | migração, dados, versão | trace=REQFUNC-031; source=user_prompt; module=migracao-dados |
| REQ-FUNC-032 | Sincronizar dados | O sistema deverá sincronizar dados do usuário com o serviço de backend configurado. | Sistema | Should | 1) Salvar alterações locais no backend; 2) Carregar dados do usuário autenticado; 3) Resolver ou sinalizar falhas de sincronização; 4) Manter associação dos dados ao usuário correto. | user_context: arquitetura/fluxo-de-dados | sincronização, backend, dados | trace=REQFUNC-032; source=user_prompt; module=arquitetura |
| REQ-FUNC-033 | Validar permissões de acesso | O sistema deverá impedir que um usuário acesse dados pertencentes a outro usuário. | Sistema | Must | 1) Associar dados ao usuário autenticado; 2) Validar permissão antes de leitura; 3) Validar permissão antes de alteração; 4) Negar acesso quando a permissão não existir. | user_context: arquitetura/seguranca | segurança, permissão, rls | trace=REQFUNC-033; source=user_prompt; module=seguranca |
| REQ-FUNC-034 | Tratar erros operacionais | O sistema deverá apresentar mensagens de erro compreensíveis quando uma operação funcional falhar. | Sistema | Must | 1) Capturar falhas de operações críticas; 2) Exibir mensagem adequada ao usuário; 3) Evitar exposição de detalhes técnicos sensíveis; 4) Permitir nova tentativa quando aplicável. | user_context: arquitetura/tratamento-de-erros | erros, snackbar, ux | trace=REQFUNC-034; source=user_prompt; module=tratamento-erros |
| REQ-FUNC-035 | Operar offline parcialmente | O sistema deverá permitir uso parcial das funcionalidades principais quando não houver conexão, conforme regras de sincronização definidas. | Usuário | Could | 1) Permitir consultar dados já carregados; 2) Registrar alterações locais quando suportado; 3) Sinalizar estado offline; 4) Sincronizar alterações quando a conexão retornar. | user_context: requisitos-nao-funcionais/offline | offline, sincronização, compras | trace=REQFUNC-035; source=user_prompt; module=offline |

---

## Requisitos Divididos

Nenhum requisito composto foi mantido como requisito único. Os comportamentos de autenticação, compras, nota fiscal, estoque, histórico, notificações, compartilhamento, migração e segurança foram separados em requisitos funcionais próprios.

---

## Rastreabilidade mínima

| ID | Fonte | Caso de Uso | Test Case ID |
|---|---|---|---|
| REQ-FUNC-001 | user_context: módulos/autenticacao | UC-AUTH-001 | TC-REQ-FUNC-001 |
| REQ-FUNC-002 | user_context: módulos/autenticacao | UC-AUTH-002 | TC-REQ-FUNC-002 |
| REQ-FUNC-003 | user_context: módulos/autenticacao | UC-AUTH-003 | TC-REQ-FUNC-003 |
| REQ-FUNC-004 | user_context: módulos/autenticacao | UC-AUTH-004 | TC-REQ-FUNC-004 |
| REQ-FUNC-005 | user_context: módulos/autenticacao | UC-AUTH-005 | TC-REQ-FUNC-005 |
| REQ-FUNC-006 | user_context: módulos/compras | UC-COMP-001 | TC-REQ-FUNC-006 |
| REQ-FUNC-007 | user_context: módulos/compras | UC-COMP-002 | TC-REQ-FUNC-007 |
| REQ-FUNC-008 | user_context: módulos/compras | UC-COMP-003 | TC-REQ-FUNC-008 |
| REQ-FUNC-009 | user_context: módulos/compras | UC-COMP-004 | TC-REQ-FUNC-009 |
| REQ-FUNC-010 | user_context: módulos/compras | UC-COMP-005 | TC-REQ-FUNC-010 |
| REQ-FUNC-011 | user_context: módulos/compras | UC-COMP-006 | TC-REQ-FUNC-011 |
| REQ-FUNC-012 | user_context: módulos/compras | UC-COMP-007 | TC-REQ-FUNC-012 |
| REQ-FUNC-013 | user_context: módulos/compras | UC-CAT-001 | TC-REQ-FUNC-013 |
| REQ-FUNC-014 | user_context: módulos/compras | UC-COMP-008 | TC-REQ-FUNC-014 |
| REQ-FUNC-015 | user_context: módulos/compras | UC-COMP-009 | TC-REQ-FUNC-015 |
| REQ-FUNC-016 | user_context: módulos/nota-fiscal | UC-NF-001 | TC-REQ-FUNC-016 |
| REQ-FUNC-017 | user_context: módulos/nota-fiscal | UC-NF-002 | TC-REQ-FUNC-017 |
| REQ-FUNC-018 | user_context: módulos/nota-fiscal | UC-NF-003 | TC-REQ-FUNC-018 |
| REQ-FUNC-019 | user_context: módulos/controle-de-estoque | UC-EST-001 | TC-REQ-FUNC-019 |
| REQ-FUNC-020 | user_context: módulos/controle-de-estoque | UC-EST-002 | TC-REQ-FUNC-020 |
| REQ-FUNC-021 | user_context: módulos/controle-de-estoque | UC-EST-003 | TC-REQ-FUNC-021 |
| REQ-FUNC-022 | user_context: módulos/controle-de-estoque | UC-EST-004 | TC-REQ-FUNC-022 |
| REQ-FUNC-023 | user_context: módulos/historico-e-fechamento | UC-HIST-001 | TC-REQ-FUNC-023 |
| REQ-FUNC-024 | user_context: módulos/historico-e-fechamento | UC-HIST-002 | TC-REQ-FUNC-024 |
| REQ-FUNC-025 | user_context: módulos/historico-e-fechamento | UC-HIST-003 | TC-REQ-FUNC-025 |
| REQ-FUNC-026 | user_context: módulos/notificacoes | UC-NOTIF-001 | TC-REQ-FUNC-026 |
| REQ-FUNC-027 | user_context: módulos/notificacoes | UC-NOTIF-002 | TC-REQ-FUNC-027 |
| REQ-FUNC-028 | user_context: módulos/notificacoes | UC-NOTIF-003 | TC-REQ-FUNC-028 |
| REQ-FUNC-029 | user_context: módulos/compartilhamento-whatsapp | UC-SHARE-001 | TC-REQ-FUNC-029 |
| REQ-FUNC-030 | user_context: módulos/compartilhamento-whatsapp | UC-SHARE-002 | TC-REQ-FUNC-030 |
| REQ-FUNC-031 | user_context: módulos/migracao-de-dados | UC-MIG-001 | TC-REQ-FUNC-031 |
| REQ-FUNC-032 | user_context: arquitetura/fluxo-de-dados | UC-SYNC-001 | TC-REQ-FUNC-032 |
| REQ-FUNC-033 | user_context: arquitetura/seguranca | UC-SEC-001 | TC-REQ-FUNC-033 |
| REQ-FUNC-034 | user_context: arquitetura/tratamento-de-erros | UC-ERR-001 | TC-REQ-FUNC-034 |
| REQ-FUNC-035 | user_context: requisitos-nao-funcionais/offline | UC-OFF-001 | TC-REQ-FUNC-035 |

---

## Checklist Final (QA)

- [x] Todos os requisitos possuem ID `REQ-FUNC-XXX` único e sequencial.
- [x] Enunciados são atômicos e iniciam com "O sistema deverá" ou equivalente.
- [x] Cada requisito tem 2–5 critérios de aceite claros e verificáveis.
- [x] Prioridade definida com MoSCoW para cada requisito.
- [x] Fonte e provenance preenchidos em todas as linhas.
- [x] Requisitos compostos foram divididos em requisitos próprios.
- [x] Não há duplicações textuais identificadas nesta versão inicial.
- [x] Tabela final exportável em Markdown pronta para rastreabilidade.

---

FIM

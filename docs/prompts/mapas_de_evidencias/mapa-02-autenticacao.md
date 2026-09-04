# Mapa de Evidências

- Documento: Autenticação
- Documento associado: `docs/03-modulos/autenticacao.md`
- Versão: v1.0
- Status: Draft
- Persona-Version: persona-08
- Last_update_date: 2026-07-25

---

# 1. Objetivo

Este documento registra todas as evidências utilizadas na elaboração do documento
`autenticacao.md`.

Seu objetivo é garantir rastreabilidade entre os documentos do projeto,
permitindo identificar a origem de cada informação utilizada.

---

# 2. Convenção

Todas as evidências seguem o formato:

```
EV-AUTH-XXX
```

onde:

- EV → Evidência
- AUTH → Documento Autenticação
- XXX → Sequencial

Exemplo:

```
EV-AUTH-001
EV-AUTH-002
EV-AUTH-003
...
```

---

# 3. Tabela de Evidências

| ID | Documento de Origem | Seção de Origem | Informação utilizada | Utilizada em |
|----|---------------------|-----------------|---------------------|--------------|
| EV-AUTH-001 | auth_service.dart | Classe AuthService | Serviço central de autenticação — email/senha e Google | Objetivo, Guia de Implementação e Integração |
| EV-AUTH-002 | login_screen.dart | Classe LoginScreen | Tela de login com suporte a e-mail/senha e Google | Objetivo, Guia de Implementação e Integração |
| EV-AUTH-003 | main.dart | Classe AuthWrapper | Wrapper que gerencia estado de autenticação | Objetivo, Guia de Implementação e Integração |
| EV-AUTH-004 | auth_service.dart | Método entrarComEmail | Login com e-mail e senha | Login com e-mail e senha, RN-AUTH-001, RN-AUTH-002, RN-AUTH-003, Guia de Implementação e Integração |
| EV-AUTH-005 | auth_service.dart | Método cadastrarComEmail | Cadastro com e-mail e senha | Registro de novo usuário, RN-AUTH-004, RN-AUTH-005, RN-AUTH-006, RN-AUTH-007, Guia de Implementação e Integração |
| EV-AUTH-006 | auth_service.dart | Método entrarComGoogle | Login com Google | Login com Google, RN-AUTH-008, RN-AUTH-009, Guia de Implementação e Integração |
| EV-AUTH-007 | auth_service.dart | Método recuperarSenha | Recuperar senha por e-mail | Recuperação de senha, RN-AUTH-010, RN-AUTH-011, Guia de Implementação e Integração |
| EV-AUTH-008 | auth_service.dart | Propriedade usuarioAtual e authStateChanges | Gerenciamento de sessão e estado de autenticação | Gerenciamento de sessão, Logout, RN-AUTH-014, RN-AUTH-015, Guia de Implementação e Integração |
| EV-AUTH-009 | auth_service.dart | Método sair | Logout | Logout, RN-AUTH-012, RN-AUTH-013, Guia de Implementação e Integração |
| EV-AUTH-010 | compras.dart | Classe Compra | Entidade de compra (referência para outro módulo) | Fora do escopo |
| EV-AUTH-011 | produto_estoque.dart | Classe ProdutoEstoque | Entidade de produto em estoque (referência para outro módulo) | Fora do escopo |
| EV-AUTH-012 | notificacao_estoque.dart | Classe NotificacaoEstoqueService | Serviço de notificação de estoque (referência para outro módulo) | Fora do escopo |
| EV-AUTH-013 | whatsapp_service.dart | Classe WhatsAppService | Serviço de compartilhamento via WhatsApp (referência para outro módulo) | Fora do escopo |
| EV-AUTH-014 | historico_screen.dart | Classe HistoricoScreen | Tela de histórico (referência para outro módulo) | Fora do escopo |
| EV-AUTH-015 | main.dart | StreamBuilder de AuthState | Propagação de estado de autenticação | Responsabilidades, Integrações, Guia de Implementação e Integração |
| EV-AUTH-016 | notification_service.dart | Classe NotificationService | Serviço de notificação push | Integrações, Guia de Implementação e Integração |

---

# 4. Estatísticas

| Item | Quantidade |
|------|-----------:|
| Evidências totais | 16 |
| Auth Service | 9 |
| Login Screen | 2 |
| Main Dart | 3 |
| Outros módulos (referências) | 2 |

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
EV-AUTH-017
EV-AUTH-018
EV-AUTH-019
...
```

Nunca reutilizar um identificador removido.

Caso uma evidência deixe de ser utilizada, mantê-la registrada com status **Obsoleta**, preservando a rastreabilidade histórica.

---

FIM
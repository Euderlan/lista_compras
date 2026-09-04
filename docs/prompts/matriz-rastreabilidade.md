# Matriz de Rastreabilidade de Implementação – Notificações

Esta matriz relaciona requisitos do módulo **Notificações** com suas implementações no código‑fonte, evidências e testes.

| ID | Problema | Objetivo | Implementação | Evidência | Teste |
|----|----------|----------|--------------|-----------|-------|
| REQ‑NOT‑001 | Usuário não recebe alerta de produtos acabando | Notificar via push quando o app está fechado | `lib/services/notification_service.dart:NotificationService.inicializar 22‑85` | `lib/services/notification_service.dart` linhas 22‑85 | PENDING |
| REQ‑NOT‑002 | Persistir token de dispositivo para receber push | Salvar token FCM no Supabase | `lib/services/notification_service.dart:NotificationService.salvarToken 87‑115` | `lib/services/notification_service.dart` linhas 87‑115 | PENDING |
| REQ‑NOT‑003 | Exibir alerta de estoque ao abrir o app | Diálogos sequenciais de estoque | `lib/services/notificacao_estoque_service.dart:NotificacaoEstoqueService.verificarENotificar 13‑33`<br>`lib/services/notificacao_estoque_service.dart:_mostrarDialogo 36‑72` | `lib/services/notificacao_estoque_service.dart` linhas 13‑33 e 36‑72 | PENDING |
| REQ‑NOT‑004 | Calcular snooze dinâmico baseado em peso/quantidade | Definir intervalo de adiamento de notificação | `lib/services/notificacao_estoque_service.dart:_calcularDiasSnooze 74‑83` | `lib/services/notificacao_estoque_service.dart` linhas 74‑83 | PENDING |
| REQ‑NOT‑005 | Disparar verificação de estoque na inicialização da UI | Chamar serviço de notificação no fluxo de navegação | `lib/main.dart:MainNavigationWrapper._verificarEstoques 141‑148` (invoca `NotificacaoEstoqueService.verificarENotificar`) | `lib/main.dart` linhas 141‑148 | PENDING |
| REQ‑NOT‑006 | Remover token ao logout para proteger privacidade | Deletar token do Supabase e do FCM | `lib/services/notification_service.dart:NotificationService.removerToken 119‑136`<br>`lib/main.dart:MainNavigationWrapper._logout 436‑438` | `lib/services/notification_service.dart` linhas 119‑136 | PENDING |

**Cobertura**
- Requisitos documentados: 6
- Implementações encontradas: 6
- Testes disponíveis: 0 (todos `PENDING`)

**Observação**: Caso haja novos requisitos ou alterações no código, atualizar a matriz de forma incremental.

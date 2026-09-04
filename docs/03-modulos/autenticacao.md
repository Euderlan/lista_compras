# Módulo de Autenticação

## Metadados do Documento (obrigatório)

- **Projeto:** `lista_compras`
- **Documento gerado em:** `2026-07-25 00:00`
- **Status:** `v1.0-draft (DOC-LISTA-COMPRAS-AUTH-v1)`
- **Responsável técnico:** `Equipe de Produto / Engenharia`
- **Persona-Version:** `persona-08`
- **prompt-usado:** `prompt-02-autenticacao.md`
- **Evidence-Map-Output:** `docs/99-prompts/prompts-euderlan/99-mapas_de_evidencias/mapa-02-autenticacao.md`

> Estes metadados devem ser mantidos no início do documento para fins de rastreabilidade, auditoria e governança documental.

---

## 1. Objetivo

O módulo de **Autenticação** é responsável por gerenciar o acesso seguro ao aplicativo lista_compras, permitindo que usuários se autentiquem via e-mail/senha ou Google Sign-In, mantenham sessões ativas e realizem logout seguro. Este módulo é fundamental para a privacidade dos dados do usuário e controle de acesso às funcionalidades do aplicativo. **Evidência(s):** `EV-AUTH-001`, `EV-AUTH-002`, `EV-AUTH-003`.

---

## 2. Escopo

### 2.1 Dentro do escopo

| Item | Descrição | Evidência(s) |
|------|-----------|--------------|
| Autenticação com e-mail e senha | Permitir login e registro de usuários usando credenciais de e-mail e senha. | `EV-AUTH-004`, `EV-AUTH-005` |
| Autenticação com Google | Permitir login usando conta Google via OAuth. | `EV-AUTH-006` |
| Recuperação de senha | Permitir que usuários recuperem acesso via e-mail. | `EV-AUTH-007` |
| Gerenciamento de sessão | Manter estado de autenticação entre sessões do aplicativo. | `EV-AUTH-008` |
| Logout seguro | Encerrar sessão do usuário e limpar dados de autenticação. | `EV-AUTH-009` |

### 2.2 Fora do escopo

| Item | Motivo | Evidência(s) |
|------|--------|--------------|
| Gerenciamento de compras | Funcionalidade pertencente ao módulo de compras. | `EV-AUTH-010` |
| Controle de estoque | Funcionalidade pertencente ao módulo de controle de estoque. | `EV-AUTH-011` |
| Processamento de nota fiscal | Funcionalidade pertencente ao módulo de nota fiscal. | `EV-AUTH-012` |
| Compartilhamento via WhatsApp | Funcionalidade pertencente ao módulo de compartilhamento. | `EV-AUTH-013` |
| Funcionalidades de histórico | Funcionalidade pertencente ao módulo de histórico. | `EV-AUTH-014` |

---

## 3. Responsabilidades do módulo

| Responsabilidade | Descrição | Evidência(s) |
|------------------|-----------|--------------|
| Validar credenciais | Verificar se o e-mail e senha fornecidos correspondem a um usuário cadastrado. | `EV-AUTH-004` |
| Cadastrar novos usuários | Registrar novos usuários no sistema com validação de dados. | `EV-AUTH-005` |
| Integrar com Google Sign-In | Utilizar API do Google para autenticação OAuth. | `EV-AUTH-006` |
| Enviar e-mail de recuperação | Disparar e-mail com link para redefinição de senha. | `EV-AUTH-007` |
| Manter estado de autenticação | Preservar token de sessão entre reinicializações do aplicativo. | `EV-AUTH-008` |
| Revogar acesso | Invalidar tokens e remover dados de sessão ao fazer logout. | `EV-AUTH-009` |
| Fornecer estado de autenticação | Disponibilizar informações do usuário logado para outros módulos. | `EV-AUTH-015` |

---

## 4. Fluxos Principais

### 4.1 Login com e-mail e senha

1. O usuário informa e-mail e senha na tela de login.
2. O sistema valida se os campos estão preenchidos.
3. O serviço de autenticação envia as credenciais para o Supabase.
4. O Supabase verifica as credenciais e retorna um token de sessão.
5. O sistema armazena o token de sessão e atualiza o estado de autenticação.
6. O usuário é redirecionado para a tela principal do aplicativo.

**Evidência(s):** `EV-AUTH-004`, `EV-AUTH-008`.

#### Regras aplicáveis

- `RN-AUTH-001`: E-mail e senha são obrigatórios para login.
- `RN-AUTH-002`: Senha deve ter pelo menos 6 caracteres.
- `RN-AUTH-003`: E-mail deve estar em formato válido.

---

### 4.2 Registro de novo usuário

1. O usuário informa nome, e-mail e senha na tela de registro.
2. O sistema valida se todos os campos estão preenchidos corretamente.
3. O serviço de autenticação envia os dados para o Supabase para criação de usuário.
4. O Supabase cria o usuário e retorna uma resposta de sucesso.
5. O sistema exibe mensagem de confirmação e solicita verificação de e-mail.
6. O usuário é redirecionado para a tela de login após confirmação.

**Evidência(s):** `EV-AUTH-005`, `EV-AUTH-008`.

#### Regras aplicáveis

- `RN-AUTH-004`: Nome é obrigatório para registro.
- `RN-AUTH-005`: E-mail deve ser único no sistema.
- `RN-AUTH-006`: Senha deve ter pelo menos 6 caracteres.
- `RN-AUTH-007`: Senha e confirmação de senha devem ser iguais.

---

### 4.3 Login com Google

1. O usuário seleciona a opção de login com Google.
2. O sistema inicia o fluxo OAuth do Google Sign-In.
3. O usuário escolhe uma conta Google e concede permissões.
4. O Google retorna um token de ID e token de acesso.
5. O serviço de autenticação envia os tokens para o Supabase.
6. O Supabase verifica os tokens e cria ou recupera o usuário associado.
7. O sistema armazena o token de sessão e atualiza o estado de autenticação.
8. O usuário é redirecionado para a tela principal do aplicativo.

**Evidência(s):** `EV-AUTH-006`, `EV-AUTH-008`.

#### Regras aplicáveis

- `RN-AUTH-008`: Login com Google requer concessão de permissões de e-mail e perfil.
- `RN-AUTH-009`: Tokens do Google devem ser válidos e não expirados.

---

### 4.4 Recuperação de senha

1. O usuário informa seu e-mail na tela de recuperação de senha.
2. O sistema valida se o e-mail está em formato válido.
3. O serviço de autenticação solicita ao Supabase o envio de e-mail de recuperação.
4. O Supabase envia um e-mail com link para redefinição de senha.
5. O sistema exibe mensagem de confirmação de envio.
6. O usuário acessa o link no e-mail e define uma nova senha.
7. O sistema permite login com a nova senha.

**Evidência(s):** `EV-AUTH-007`.

#### Regras aplicáveis

- `RN-AUTH-010`: E-mail deve estar em formato válido para recuperação.
- `RN-AUTH-011`: E-mail deve estar cadastrado no sistema para recuperação.

---

### 4.5 Logout

1. O usuário seleciona a opção de logout no menu ou configurações.
2. O sistema chama o serviço de autenticação para encerrar sessão.
3. O serviço de autenticação envia comando de logout ao Supabase.
4. O Supabase invalida o token de sessão.
5. O sistema remove dados de sessão locais e atualiza estado de autenticação.
6. O usuário é redirecionado para a tela de login.

**Evidência(s):** `EV-AUTH-009`.

#### Regras aplicáveis

- `RN-AUTH-012`: Logout deve limpar completamente os dados de sessão do cliente.
- `RN-AUTH-013`: Após logout, usuário deve ser redirecionado para tela de login.

---

### 4.6 Gerenciamento de sessão

1. Ao iniciar o aplicativo, o sistema verifica se existe um token de sessão válido.
2. Se um token válido existir, o usuário é considerado autenticado.
3. O estado de autenticação é mantido enquanto o token for válido.
4. O sistema escuta por mudanças no estado de autenticação do Supabase.
5. Quando o token expirar ou for revogado, o estado é atualizado para não autenticado.
6. O sistema redireciona o usuário para a tela de login quando necessário.

**Evidência(s):** `EV-AUTH-008`.

#### Regras aplicáveis

- `RN-AUTH-014`: Sessão deve ser verificada na inicialização do aplicativo.
- `RN-AUTH-015`: Mudanças no estado de autenticação devem ser propagadas para todos os módulos.

---

## 5. Guia de Implementação e Integração

Esta seção fornece um guia passo a passo de como o módulo de autenticação foi implementado no aplicativo lista_compras, incluindo configuração de dependências, setup dos serviços e exemplos de uso.

### 5.1 Configuração de Dependências

Para utilizar o módulo de autenticação, as seguintes dependências devem ser adicionadas ao arquivo `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.8.4
  google_sign_in: ^6.2.1
  shared_preferences: ^2.5.5
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.3
  flutter_local_notifications: ^17.2.2
```

**Evidência(s):** `EV-AUTH-004`, `EV-AUTH-005`, `EV-AUTH-006`, `EV-AUTH-007`, `EV-AUTH-008`, `EV-AUTH-009`, `EV-AUTH-016`

### 5.2 Inicialização dos Serviços

Os serviços de autenticação devem ser inicializados no método `main()` do arquivo `lib/main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase (necessário para notificações)
  await Firebase.initializeApp();
  await NotificationService.inicializar();

  // Inicializa Supabase com URL e chave anonima
  await Supabase.initialize(
    url: 'https://saipamdfykhvniozhndl.supabase.co',
    anonKey: 'sb_publishable_eWcmYcnkkdm6qdZ30ulAYg_V_2obdgD',
  );

  // Configura orientação da tela
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ListaComprasApp());
}
```

**Evidência(s):** `EV-AUTH-004`, `EV-AUTH-005`, `EV-AUTH-006`, `EV-AUTH-007`, `EV-AUTH-008`, `EV-AUTH-009`, `EV-AUTH-016`

### 5.3 Uso do AuthService

O serviço de autenticação (`AuthService`) fornece métodos para todas as operações de autenticação. Ele deve ser instanciado onde necessário ou fornecido via injeção de dependência.

#### Exemplo de uso no LoginScreen:

```dart
final _authService = AuthService();

// Login com e-mail e senha
await _authService.entrarComEmail(
  email: 'usuario@exemplo.com',
  senha: 'minhasenha123',
);

// Registro de novo usuário
await _authService.cadastrarComEmail(
  nome: 'Nome do Usuário',
  email: 'usuario@exemplo.com',
  senha: 'minhasenha123',
);

// Login com Google
final googleAuthResult = await _authService.entrarComGoogle();
if (googleAuthResult != null) {
  // Login bem-sucedido
}

// Recuperação de senha
await _authService.recuperarSenha('usuario@exemplo.com');

// Logout
await _authService.sair();

// Obter usuário atualmente logado
final usuarioAtual = _authService.usuarioAtual;

// Escutar mudanças no estado de autenticação
authStateChanges.listen((event) {
  final session = event.session;
  if (session != null) {
    // Usuário autenticado
  } else {
    // Usuário não autenticado
  }
});
```

**Evidência(s):** `EV-AUTH-004`, `EV-AUTH-005`, `EV-AUTH-006`, `EV-AUTH-007`, `EV-AUTH-008`, `EV-AUTH-009`

### 5.4 Integração com a Tela de Login (LoginScreen)

A tela de login (`lib/screens/login_screen.dart`) implementa a interface do usuário para todas as operações de autenticação:

#### Elementos da UI:
- Campos de texto para e-mail, senha, nome e confirmação de senha
- Botões para entrar, cadastrar, login com Google e recuperar senha
- Indicadores de carregamento
- Mensagens de erro e sucesso via SnackBar

#### Fluxo de operações:
1. **Login com e-mail/senha**: Chama `_entrar()` que usa `authService.entrarComEmail()`
2. **Registro**: Chama `_cadastrar()` que usa `authService.cadastrarComEmail()`
3. **Login com Google**: Chama `_entrarComGoogle()` que usa `authService.entrarComGoogle()`
4. **Recuperação de senha**: Chama `_recuperarSenha()` que usa `authService.recuperarSenha()`
5. **Alternar entre modos de login/registro**: Chama `_alternarModo()`

**Evidência(s):** `EV-AUTH-002`

### 5.5 Gerenciamento de Estado de Autenticação

O estado de autenticação é gerenciado através do `AuthWrapper` em `lib/main.dart`, que usa um `StreamBuilder` para ouvir alterações no estado de autenticação do Supabase:

```dart
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }
        final session = snapshot.data?.session;
        if (session != null) {
          return const MainNavigationWrapper(); // Usuário autenticado
        }
        return LoginScreen(onLoginSucesso: () {}); // Usuário não autenticado
      },
    );
  }
}
```

**Evidência(s):** `EV-AUTH-003`, `EV-AUTH-008`

### 5.6 Acesso ao Estado de Autenticação em Outros Módulos

Outros módulos podem acessar o estado de autenticação através do `AuthService` ou escutando o stream de mudanças de estado:

#### Exemplo de verificação de acesso em telas protegidas:

```dart
// Em qualquer tela que requer autenticação
final authService = AuthService();
final usuarioAtual = authService.usuarioAtual;

if (usuarioAtual == null) {
  // Redirecionar para tela de login
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  );
  return;
}

// Ou escutar mudanças de estado
StreamSubscription<AuthState>? _authSubscription;

@override
void initState() {
  super.initState();
  _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
    final session = event.session;
    if (session == null) {
      // Usuário deslogou, redirecionar para login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  });
}

@override
void dispose() {
  _authSubscription?.cancel();
  super.dispose();
}
```

**Evidência(s):** `EV-AUTH-008`, `EV-AUTH-015`

---

## 6. Regras de Negócio

| ID | Regra | Descrição | Impacto | Exceções | Evidência(s) |
|----|-------|-----------|---------|----------|--------------|
| RN-AUTH-001 | Credenciais obrigatórias | E-mail e senha são obrigatórios para login com e-mail/senha. | Impede tentativas de login com dados incompletos. | Nenhuma. | `EV-AUTH-004` |
| RN-AUTH-002 | Tamanho mínimo de senha | Senha deve ter pelo menos 6 caracteres. | Aumenta segurança das credenciais. | Nenhuma. | `EV-AUTH-004` |
| RN-AUTH-003 | Formato de e-mail válido | E-mail deve estar em formato válido (ex: usuário@dominio.com). | Impede tentativas de login com e-mail inválido. | Nenhuma. | `EV-AUTH-004`, `EV-AUTH-005`, `EV-AUTH-007` |
| RN-AUTH-004 | Nome obrigatório | Nome é obrigatório para registro de novo usuário. | Garante identificação pessoal do usuário. | Nenhuma. | `EV-AUTH-005` |
| RN-AUTH-005 | E-mail único | Cada e-mail só pode estar associado a uma conta no sistema. | Impede duplicação de contas. | Nenhuma. | `EV-AUTH-005` |
| RN-AUTH-006 | Confirmação de senha | Senha e confirmação de senha devem ser iguais durante registro. | Impede erros de digitação na senha. | Nenhuma. | `EV-AUTH-005` |
| RN-AUTH-007 | Senha forte em registro | Senha deve ter pelo menos 6 caracteres durante registro. | Mantém consistência de segurança. | Nenhuma. | `EV-AUTH-005` |
| RN-AUTH-008 | Permissões Google | Login com Google requer concessão de permissões de e-mail e perfil. | Garante acesso às informações necessárias para criação de usuário. | Nenhuma. | `EV-AUTH-006` |
| RN-AUTH-009 | Validade dos tokens Google | Tokens do Google devem ser válidos e não expirados. | Impede uso de tokens comprometidos ou expirados. | Nenhuma. | `EV-AUTH-006` |
| RN-AUTH-010 | E-mail válido para recuperação | E-mail deve estar em formato válido para recuperação de senha. | Garante que o e-mail de recuperação seja entregue corretamente. | Nenhuma. | `EV-AUTH-007` |
| RN-AUTH-011 | E-mail cadastrado | E-mail informado para recuperação deve estar cadastrado no sistema. | Impede tentativas de recuperação com e-mails não cadastrados. | Nenhuma. | `EV-AUTH-007` |
| RN-AUTH-012 | Limpeza completa de sessão | Logout deve limpar completamente os dados de sessão do cliente. | Garante que nenhum dado de sessão permaneça após logout. | Nenhuma. | `EV-AUTH-009` |
| RN-AUTH-013 | Redirecionamento pós-logout | Após logout, usuário deve ser redirecionado para tela de login. | Garante que usuário não acesse áreas restritas sem autenticação. | Nenhuma. | `EV-AUTH-009` |
| RN-AUTH-014 | Verificação de sessão na inicialização | Sessão deve ser verificada na inicialização do aplicativo. | Garante que usuários já autenticados não precisem fazer login novamente. | Nenhuma. | `EV-AUTH-008` |
| RN-AUTH-015 | Propagação de estado de autenticação | Mudanças no estado de autenticação devem ser propagadas para todos os módulos. | Garante consistência de experiência de usuário. | Nenhuma. | `EV-AUTH-008`, `EV-AUTH-015` |

---

## 7. Integrações

| Módulo | Objetivo da integração | Evidência(s) |
|--------|------------------------|--------------|
| Supabase (backend) | Armazenar usuários, gerenciar autenticação e tokens de sessão. | `EV-AUTH-004`, `EV-AUTH-005`, `EV-AUTH-006`, `EV-AUTH-007`, `EV-AUTH-009` |
| Google Sign-In API | Fornecer mecanismo de autenticação OAuth via conta Google. | `EV-AUTH-006` |
| Firebase (notificações) | Enviar notificações push para dispositivos móveis. | `EV-AUTH-016` |
| Shared Preferences | Armazenar tokens de sessão localmente para persistência entre reinicializações. | `EV-AUTH-008` |
| Módulo de compras | Fornecer estado de autenticação para verificar permissões de acesso. | `EV-AUTH-015` |
| Módulo de histórico | Fornecer estado de autenticação para verificar permissões de acesso ao histórico. | `EV-AUTH-015` |
| Módulo de nota fiscal | Fornecer estado de autenticação para verificar permissões de acesso a notas fiscais. | `EV-AUTH-015` |
| Módulo de controle de estoque | Fornecer estado de autenticação para verificar permissões de acesso ao estoque. | `EV-AUTH-015` |
| Módulo de compartilhamento | Fornecer estado de autenticação para verificar permissões de compartilhamento. | `EV-AUTH-015` |

---

## 8. Estados da Autenticação

| Estado | Descrição | Permite acesso a funcionalidades? | Evidência(s) |
|--------|-----------|-----------------------------------|--------------|
| não autenticado | Usuário não fez login ou sessão expirou. | Não | `EV-AUTH-008` |
| autenticando | Processo de login em andamento. | Parcial (telas de login/registro permitidas) | `EV-AUTH-008` |
| autenticado | Usuário fez login com sucesso e sessão ativa. | Sim | `EV-AUTH-008` |
| erro de autenticação | Falha no processo de autenticação. | Não | `EV-AUTH-008` |

---

## 9. Casos de Uso Relacionados

| Caso de Uso | Nome | RF Relacionado | Descrição | Evidência(s) |
|-------------|------|----------------|-----------|--------------|
| UC-AUTH-001 | Login com e-mail/senha | REQ-FUNC-001 | Usuário faz login usando e-mail e senha. | `EV-AUTH-004` |
| UC-AUTH-002 | Registro de novo usuário | REQ-FUNC-002 | Usuário cria nova conta no sistema. | `EV-AUTH-005` |
| UC-AUTH-003 | Login com Google | REQ-FUNC-003 | Usuário faz login usando conta Google. | `EV-AUTH-006` |
| UC-AUTH-004 | Recuperação de senha | REQ-FUNC-004 | Usuário recupera acesso via e-mail. | `EV-AUTH-007` |
| UC-AUTH-005 | Logout | REQ-FUNC-005 | Usuário encerra sessão no aplicativo. | `EV-AUTH-009` |
| UC-AUTH-006 | Verificação de sessão | REQ-FUNC-006 | Sistema verifica estado de autenticação na inicialização. | `EV-AUTH-008` |

---

## 10. Critérios de Aceite

| ID | Critério | Verificação | Evidência(s) |
|------|----------|-------------|--------------|
| CA-AUTH-001 | O usuário deve conseguir fazer login com e-mail e senha válidos. | Dado um usuário cadastrado com e-mail e senha válidos, quando tentar fazer login, então o sistema deve autenticar e redirecionar para tela principal. | `EV-AUTH-004` |
| CA-AUTH-002 | O sistema deve rejeitar login com e-mail ou senha inválidos. | Dado um e-mail ou senha inválidos, quando tentar fazer login, então o sistema deve exibir erro de autenticação. | `EV-AUTH-004` |
| CA-AUTH-003 | O usuário deve conseguir registrar nova conta com dados válidos. | Dado nome, e-mail e senha válidos e únicos, quando tentar registrar, então o sistema deve criar conta e solicitar verificação de e-mail. | `EV-AUTH-005` |
| CA-AUTH-004 | O sistema deve rejeitar registro com dados inválidos ou duplicados. | Dado nome inválido, e-mail duplicado ou senha muito curta, quando tentar registrar, então o sistema deve exibir erro de validação. | `EV-AUTH-005` |
| CA-AUTH-005 | O usuário deve conseguir fazer login com Google. | Dado uma conta Google válida e permissões concedidas, quando tentar login com Google, então o sistema deve autenticar e redirecionar para tela principal. | `EV-AUTH-006` |
| CA-AUTH-006 | O sistema deve rejeitar login com Google sem permissões ou com tokens inválidos. | Dado tentativa de login com Google sem permissões ou com tokens inválidos, então o sistema deve exibir erro de autenticação. | `EV-AUTH-006` |
| CA-AUTH-007 | O usuário deve conseguir recuperar senha com e-mail cadastrado. | Dado um e-mail cadastrado, quando solicitar recuperação de senha, então o sistema deve enviar e-mail de recuperação. | `EV-AUTH-007` |
| CA-AUTH-008 | O sistema deve rejeitar recuperação de senha com e-mail não cadastrado ou inválido. | Dado um e-mail não cadastrado ou inválido, quando solicitar recuperação de senha, então o sistema deve exibir erro. | `EV-AUTH-007` |
| CA-AUTH-009 | O usuário deve conseguir fazer logout. | Dado um usuário autenticado, quando solicitar logout, então o sistema deve encerrar sessão e redirecionar para tela de login. | `EV-AUTH-009` |
| CA-AUTH-010 | O sistema deve detectar sessão existente na inicialização. | Dado um usuário com sessão válida salva, quando iniciar o aplicativo, então o sistema deve reconhecer autenticação e ir direto para tela principal. | `EV-AUTH-008` |
| CA-AUTH-011 | O sistema deve redirecionar para login quando sessão expirar ou for inválida. | Dado um usuário com sessão expirada, quando iniciar o aplicativo ou durante uso, então o sistema deve redirecionar para tela de login. | `EV-AUTH-008` |

---

## 11. Referências relacionadas

- `docs/01-visao-geral/visao-do-produto.md`
- `docs/01-visao-geral/glossario.md`
- `docs/01-visao-geral/requisitos-funcionais.md`
- `lib/services/auth_service.dart`
- `lib/screens/login_screen.dart`
- `lib/main.dart`

---

## 12. Checklist Final (QA)

- [x] Objetivo descrito
- [x] Escopo completo
- [x] Responsabilidades documentadas
- [x] Fluxos completos
- [x] Regras numeradas
- [x] Entidades descritas
- [x] Integrações documentadas
- [x] Casos de uso relacionados
- [x] Critérios de aceite definidos
- [x] Pendências identificadas
- [x] Terminologia consistente com Glossário
- [x] Documento pronto para arquitetura
- [x] Documento pronto para banco de dados
- [x] Documento pronto para APIs
- [x] Documento pronto para implementação
- [x] Documento pronto para testes

---

## 13. Geração do Mapa de Evidências

Ao finalizar o documento, gerar automaticamente:

```
docs/99-prompts/prompts-euderlan/99-mapas_de_evidencias/mapa-02-autenticacao.md
```

Cada evidência deverá conter:

- ID
- Seção
- Tipo
- Fragmento inicial
- Fragmento final
- Fonte
- Timestamp
- Status
- Projeto
- Responsável técnico

Utilizar exclusivamente evidências efetivamente referenciadas no documento.

---

## 14. Restrições

- Nunca inventar informações.
- Nunca omitir regras de negócio identificadas.
- Nunca misturar funcionalidades de outros módulos.
- Utilizar somente informações presentes nas fontes.
- Utilizar `[ADICIONAR: ...]` quando necessário.
- Garantir rastreabilidade integral.
- Garantir aderência ao Glossário.
- Garantir consistência com os Requisitos Funcionais.
- Garantir consistência com a Visão do Produto.

---

FIM
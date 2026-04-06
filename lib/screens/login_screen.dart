import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSucesso;

  const LoginScreen({super.key, required this.onLoginSucesso});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _modoLogin = true;

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _nomeController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _senhaVisivel = false;
  bool _carregando = false;

  final _authService = AuthService();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _nomeController.dispose();
    _confirmarSenhaController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _alternarModo() {
    _animController.reverse().then((_) {
      setState(() {
        _modoLogin = !_modoLogin;
        _senhaController.clear();
        _confirmarSenhaController.clear();
      });
      _animController.forward();
    });
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensagem),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _mostrarSucesso(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensagem),
      backgroundColor: AppColors.accent,
      behavior: SnackBarBehavior.floating,
    ));
  }

  String _traduzirErro(String erro) {
    if (erro.contains('Invalid login credentials')) return 'E-mail ou senha incorretos';
    if (erro.contains('Email not confirmed')) return 'Confirme seu e-mail antes de entrar';
    if (erro.contains('User already registered')) return 'Este e-mail ja esta cadastrado';
    if (erro.contains('Password should be at least')) return 'Senha deve ter pelo menos 6 caracteres';
    if (erro.contains('Unable to validate email address')) return 'E-mail invalido';
    if (erro.contains('network')) return 'Sem conexao com a internet';
    return 'Erro inesperado. Tente novamente.';
  }

  Future<void> _entrar() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      _mostrarErro('Preencha e-mail e senha');
      return;
    }

    setState(() => _carregando = true);
    try {
      await _authService.entrarComEmail(email: email, senha: senha);
      // O StreamBuilder no AuthWrapper detecta e redireciona automaticamente
    } on AuthException catch (e) {
      _mostrarErro(_traduzirErro(e.message));
    } catch (e) {
      _mostrarErro('Erro ao conectar. Verifique sua internet.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _cadastrar() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text;
    final confirmar = _confirmarSenhaController.text;

    if (nome.isEmpty) { _mostrarErro('Informe seu nome'); return; }
    if (email.isEmpty || !email.contains('@')) { _mostrarErro('E-mail invalido'); return; }
    if (senha.length < 6) { _mostrarErro('Senha deve ter pelo menos 6 caracteres'); return; }
    if (senha != confirmar) { _mostrarErro('As senhas nao coincidem'); return; }

    setState(() => _carregando = true);
    try {
      final response = await _authService.cadastrarComEmail(
        nome: nome, email: email, senha: senha,
      );
      if (response.user != null && response.session == null) {
        _mostrarSucesso('Verifique seu e-mail para confirmar o cadastro');
        _alternarModo();
      }
      // Se session != null o StreamBuilder redireciona automaticamente
    } on AuthException catch (e) {
      _mostrarErro(_traduzirErro(e.message));
    } catch (e) {
      _mostrarErro('Erro ao cadastrar. Verifique sua internet.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _entrarComGoogle() async {
    setState(() => _carregando = true);
    try {
      final response = await _authService.entrarComGoogle();
      if (response == null) _mostrarErro('Login com Google cancelado');
      // Se ok o StreamBuilder redireciona automaticamente
    } on AuthException catch (e) {
      _mostrarErro(_traduzirErro(e.message));
    } catch (e) {
      _mostrarErro('Erro ao entrar com Google. Tente novamente.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _recuperarSenha() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _mostrarErro('Digite seu e-mail acima para recuperar a senha');
      return;
    }
    setState(() => _carregando = true);
    try {
      await _authService.recuperarSenha(email);
      _mostrarSucesso('E-mail de recuperacao enviado para $email');
    } catch (e) {
      _mostrarErro('Erro ao enviar e-mail de recuperacao');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopo(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: FadeTransition(opacity: _fadeAnim, child: _buildCard()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 38),
          ),
          const SizedBox(height: 14),
          const Text('Lista de Compras',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(
            _modoLogin ? 'Entre na sua conta' : 'Crie sua conta gratuita',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAlternador(),
            const SizedBox(height: 24),
            if (!_modoLogin) ...[
              _buildCampo(controller: _nomeController, label: 'Nome completo', icone: Icons.person_outline, placeholder: 'Seu nome'),
              const SizedBox(height: 14),
            ],
            _buildCampo(controller: _emailController, label: 'E-mail', icone: Icons.email_outlined, placeholder: 'seu@email.com', teclado: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _buildCampoSenha(controller: _senhaController, label: 'Senha', placeholder: _modoLogin ? 'Sua senha' : 'Minimo 6 caracteres'),
            if (!_modoLogin) ...[
              const SizedBox(height: 14),
              _buildCampoSenha(controller: _confirmarSenhaController, label: 'Confirmar senha', placeholder: 'Repita a senha'),
            ],
            if (_modoLogin) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _recuperarSenha,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: const Text('Esqueci minha senha', style: TextStyle(fontSize: 13, color: AppColors.accent)),
                ),
              ),
            ],
            const SizedBox(height: 24),
            _buildBotaoPrincipal(),
            const SizedBox(height: 16),
            _buildDivisor(),
            const SizedBox(height: 16),
            _buildBotaoGoogle(),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _alternarModo,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14),
                    children: [
                      TextSpan(text: _modoLogin ? 'Nao tem conta? ' : 'Ja tem conta? ', style: const TextStyle(color: AppColors.textSecondary)),
                      TextSpan(text: _modoLogin ? 'Cadastre-se' : 'Entrar', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternador() {
    return Container(
      decoration: BoxDecoration(color: AppColors.searchBackground, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        _TabAlternador(label: 'Entrar', ativo: _modoLogin, onTap: () { if (!_modoLogin) _alternarModo(); }),
        _TabAlternador(label: 'Cadastrar', ativo: !_modoLogin, onTap: () { if (_modoLogin) _alternarModo(); }),
      ]),
    );
  }

  Widget _buildCampo({required TextEditingController controller, required String label, required IconData icone, required String placeholder, TextInputType teclado = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller, keyboardType: teclado,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: placeholder,
            prefixIcon: Icon(icone, size: 20, color: AppColors.textTertiary),
            filled: true, fillColor: AppColors.searchBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildCampoSenha({required TextEditingController controller, required String label, required String placeholder}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller, obscureText: !_senhaVisivel,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: placeholder,
            prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.textTertiary),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _senhaVisivel = !_senhaVisivel),
              child: Icon(_senhaVisivel ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.textTertiary),
            ),
            filled: true, fillColor: AppColors.searchBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildBotaoPrincipal() {
    return SizedBox(
      width: double.infinity, height: 50,
      child: ElevatedButton(
        onPressed: _carregando ? null : (_modoLogin ? _entrar : _cadastrar),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primaryDark.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _carregando
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Text(_modoLogin ? 'Entrar' : 'Criar conta', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildDivisor() {
    return Row(children: [
      const Expanded(child: Divider(color: AppColors.border)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('ou', style: TextStyle(fontSize: 13, color: AppColors.textTertiary))),
      const Expanded(child: Divider(color: AppColors.border)),
    ]);
  }

  Widget _buildBotaoGoogle() {
    return SizedBox(
      width: double.infinity, height: 50,
      child: OutlinedButton(
        onPressed: _carregando ? null : _entrarComGoogle,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.g_mobiledata, size: 24, color: Colors.red),
            SizedBox(width: 10),
            Text('Continuar com Google', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _TabAlternador extends StatelessWidget {
  final String label;
  final bool ativo;
  final VoidCallback onTap;

  const _TabAlternador({required this.label, required this.ativo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: ativo ? AppColors.primaryDark : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ativo ? Colors.white : AppColors.textSecondary)),
        ),
      ),
    );
  }
}
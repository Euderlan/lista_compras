import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'models/compra.dart';
import 'models/produto_acabando.dart';
import 'screens/home_screen.dart';
import 'screens/historico_screen.dart';
import 'screens/compras_futuras_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/compras_service.dart';
import 'services/produtos_acabando_service.dart';
import 'services/historico_service.dart';
import 'widgets/app_bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://saipamdfykhvniozhndl.supabase.co',
    anonKey: 'sb_publishable_eWcmYcnkkdm6qdZ30ulAYg_V_2obdgD',
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ListaComprasApp());
}

class ListaComprasApp extends StatelessWidget {
  const ListaComprasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista Compras',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthWrapper(),
    );
  }
}

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
          return const MainNavigationWrapper();
        }
        return LoginScreen(onLoginSucesso: () {});
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF2D5016),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 56),
            SizedBox(height: 16),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _abaAtual = 0;
  List<Compra> _comprasMesAtual = [];
  List<ResumoMes> _historico = [];
  List<ProdutoAcabando> _produtosAcabando = [];
  bool _carregandoDados = true;

  final _authService = AuthService();
  final _comprasService = ComprasService();
  final _produtosService = ProdutosAcabandoService();
  final _historicoService = HistoricoService();

  final String _mesAno = _obterMesAno();

  static String _obterMesAno() {
    final agora = DateTime.now();
    const meses = [
      'Janeiro','Fevereiro','Marco','Abril','Maio','Junho',
      'Julho','Agosto','Setembro','Outubro','Novembro','Dezembro',
    ];
    return '${meses[agora.month - 1]} ${agora.year}';
  }

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final compras = await _comprasService.buscarComprasMes(_mesAno);
      final produtos = await _produtosService.buscarProdutos();
      final historico = await _historicoService.buscarHistorico();
      if (mounted) {
        setState(() {
          _comprasMesAtual = compras;
          _produtosAcabando = produtos;
          _historico = historico;
          _carregandoDados = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregandoDados = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erro ao carregar dados. Verifique sua conexao.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _adicionarCompra(Compra compra) async {
    try {
      final nova = await _comprasService.adicionarCompra(compra, _mesAno);
      setState(() => _comprasMesAtual.add(nova));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erro ao salvar compra.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _removerCompra(String id) async {
    try {
      await _comprasService.removerCompra(id);
      setState(() => _comprasMesAtual.removeWhere((c) => c.id == id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erro ao remover compra.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _editarCompra(Compra compraEditada) async {
    try {
      final atualizada = await _comprasService.atualizarCompra(compraEditada);
      setState(() {
        final i = _comprasMesAtual.indexWhere((c) => c.id == atualizada.id);
        if (i != -1) _comprasMesAtual[i] = atualizada;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erro ao atualizar compra.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _adicionarProdutoAcabando(ProdutoAcabando produto) async {
    try {
      final novo = await _produtosService.adicionarProduto(produto);
      setState(() => _produtosAcabando.add(novo));
    } catch (_) {}
  }

  Future<void> _fecharMes() async {
    if (_comprasMesAtual.isEmpty) return;
    final agora = DateTime.now();
    const meses = [
      'Janeiro','Fevereiro','Marco','Abril','Maio','Junho',
      'Julho','Agosto','Setembro','Outubro','Novembro','Dezembro',
    ];
    final totalGasto = _comprasMesAtual.fold<double>(0, (s, c) => s + c.total);
    final resumo = ResumoMes(
      mes: meses[agora.month - 1],
      ano: agora.year,
      totalGasto: totalGasto,
      totalCompras: _comprasMesAtual.length,
      concluido: true,
    );
    try {
      await _historicoService.salvarResumoMes(resumo);
      await _comprasService.removerComprasMes(_mesAno);
      setState(() {
        _historico.insert(0, resumo);
        _comprasMesAtual.clear();
        _abaAtual = 2;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Mes fechado! Confira o historico.'),
          backgroundColor: Color(0xFF2D5016),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erro ao fechar o mes. Tente novamente.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _logout() async {
    await _authService.sair();
  }

  void _trocarAba(int index) => setState(() => _abaAtual = index);

  Widget _buildTela() {
    if (_carregandoDados) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F0),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF2D5016))),
      );
    }
    switch (_abaAtual) {
      case 0:
        return HomeScreen(
          compras: _comprasMesAtual,
          mesAno: _mesAno,
          onAdicionarCompra: _adicionarCompra,
          onMarcarAcabando: _adicionarProdutoAcabando,
          onEditarCompra: _editarCompra,
          onFecharMes: _fecharMes,
          onLogout: _logout,
          onRemoverCompra: _removerCompra,
        );
      case 1:
        return ComprasFuturasScreen(
          produtosAcabando: _produtosAcabando,
          onAdicionarCompra: _adicionarCompra,
        );
      case 2:
        return HistoricoScreen(historico: _historico);
      default:
        return HomeScreen(
          compras: _comprasMesAtual,
          mesAno: _mesAno,
          onAdicionarCompra: _adicionarCompra,
          onMarcarAcabando: _adicionarProdutoAcabando,
          onEditarCompra: _editarCompra,
          onFecharMes: _fecharMes,
          onLogout: _logout,
          onRemoverCompra: _removerCompra,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildTela(),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _abaAtual,
        onTap: _trocarAba,
      ),
    );
  }
}
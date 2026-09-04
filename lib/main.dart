import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'models/compra.dart';
import 'models/produto_acabando.dart';
import 'models/produto_estoque.dart';
import 'screens/home_screen.dart';
import 'screens/historico_screen.dart';
import 'screens/estoque_screen.dart';
import 'screens/compras_futuras_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/compras_service.dart';
import 'services/produtos_acabando_service.dart';
import 'services/historico_service.dart';
import 'services/produto_estoque_service.dart';
import 'services/notificacao_estoque_service.dart';
import 'widgets/app_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();         
  await NotificationService.inicializar();

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
  final _estoqueService = ProdutoEstoqueService();
  final _notificacaoService = NotificacaoEstoqueService();

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
    _migrarDadosAntigos();
    _verificarMudancaDeMes();
    NotificationService.salvarToken();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarEstoques();
    });
  }

  Future<void> _verificarEstoques() async {
    if (!mounted) return;
    await _notificacaoService.verificarENotificar(
      context: context,
      mesAno: _mesAno,
      onProdutoAcabou: _adicionarProdutoAcabando,
    );
  }

  Future<void> _verificarMudancaDeMes() async {
    final prefs = await SharedPreferences.getInstance();
    final mesAnoSalvo = prefs.getString('ultimo_mes_ano');

    if (mesAnoSalvo != null && mesAnoSalvo != _mesAno) {
      await _fecharMesAutomatico(mesAnoSalvo);
    }

    await prefs.setString('ultimo_mes_ano', _mesAno);
  }

  Future<void> _migrarDadosAntigos() async {
    final prefs = await SharedPreferences.getInstance();
    final migrado = prefs.getBool('migracao_meses_antigos_v1') ?? false;
    if (migrado) return;

    try {
      final response = await Supabase.instance.client
          .from('compras')
          .select('mes_ano')
          .eq('usuario_id', Supabase.instance.client.auth.currentUser!.id);

      final meses = (response as List)
          .map((r) => r['mes_ano'] as String)
          .toSet()
          .where((m) => m != _mesAno)
          .toList();

      for (final mesAno in meses) {
        final compras = await _comprasService.buscarComprasMes(mesAno);
        if (compras.isEmpty) continue;

        final partes = mesAno.split(' ');
        final mes = partes[0];
        final ano = int.tryParse(partes[1]) ?? DateTime.now().year;
        final totalGasto = compras.fold<double>(0, (s, c) => s + c.total);

        final jaExiste = _historico.any((h) => h.mes == mes && h.ano == ano);
        if (jaExiste) continue;

        final resumo = ResumoMes(
          mes: mes,
          ano: ano,
          totalGasto: totalGasto,
          totalCompras: compras.length,
          concluido: true,
        );

        await _historicoService.salvarResumoMes(resumo);
        await _comprasService.removerComprasMes(mesAno);
      }

      await prefs.setBool('migracao_meses_antigos_v1', true);

      final historicoAtualizado = await _historicoService.buscarHistorico();
      if (mounted) {
        setState(() {
          _historico = historicoAtualizado;
        });
      }
    } catch (e) {
      // Falha silenciosa — tenta novamente na próxima abertura
    }
  }

  Future<void> _fecharMesAutomatico(String mesAnoAnterior) async {
    try {
      final comprasAntigas =
          await _comprasService.buscarComprasMes(mesAnoAnterior);
      if (comprasAntigas.isEmpty) return;

      final partes = mesAnoAnterior.split(' ');
      final mes = partes[0];
      final ano = int.tryParse(partes[1]) ?? DateTime.now().year;
      final totalGasto = comprasAntigas.fold<double>(0, (s, c) => s + c.total);

      final resumo = ResumoMes(
        mes: mes,
        ano: ano,
        totalGasto: totalGasto,
        totalCompras: comprasAntigas.length,
        concluido: true,
      );

      await _historicoService.salvarResumoMes(resumo);
      await _comprasService.removerComprasMes(mesAnoAnterior);

      if (mounted) {
        setState(() {
          _historico.insert(0, resumo);
          _abaAtual = 2;
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Mês anterior fechado automaticamente! Confira o histórico.'),
          backgroundColor: Color(0xFF2D5016),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ));
      }
    } catch (e) {
      // Falha silenciosa — não interrompe o usuário
    }
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

  // Salva compras da nota fiscal e registra no estoque para rastreamento
Future<void> _adicionarComprasNota(
  List<Compra> compras,
  List<Map<String, dynamic>> estoques,
) async {
  for (final compra in compras) {
    await _adicionarCompra(compra);
  }

  // Remove produtos semelhantes da lista futura automaticamente
  final nomesComprados = compras.map((c) => c.nome).toList();
  try {
    final removidos =
        await _produtosService.removerSemelhantes(nomesComprados);
    if (removidos.isNotEmpty && mounted) {
      setState(() {
        _produtosAcabando.removeWhere(
          (p) => removidos.any((r) =>
              r.toLowerCase() == p.nome.toLowerCase()),
        );
      });
    }
  } catch (_) {}

  for (final dadosEstoque in estoques) {
    try {
      final produto = ProdutoEstoque(
        id: '',
        usuarioId: '',
        nome: dadosEstoque['nome'] as String,
        categoria: dadosEstoque['categoria'] as Categoria,
        quantidade: (dadosEstoque['quantidade'] as num).toDouble(),
        unidade: dadosEstoque['unidade'] as String,
        pesoUnitario: (dadosEstoque['peso_unitario'] as num).toDouble(),
                  precoUnitario: (dadosEstoque['preco_unitario'] as num).toDouble(),
          dataCompra: DateTime.now(),
        mesAno: _mesAno,
      );
      await _estoqueService.upsertProduto(produto);
    } catch (_) {}
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
Future<void> _atualizarProdutoAcabando(ProdutoAcabando produto) async {
  try {
    final atualizado = await _produtosService.atualizarProduto(produto);
    setState(() {
      final i = _produtosAcabando.indexWhere((p) => p.id == atualizado.id);
      if (i != -1) _produtosAcabando[i] = atualizado;
    });
  } catch (_) {}
}

Future<void> _removerProdutoAcabando(String id) async {
  try {
    await _produtosService.removerProduto(id);
    setState(() => _produtosAcabando.removeWhere((p) => p.id == id));
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
      await _estoqueService.removerProdutosMes(_mesAno);
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
    await NotificationService.removerToken();
    await _authService.sair();
  }

  void _trocarAba(int index) => setState(() => _abaAtual = index);

  Widget _buildTela() {
    if (_carregandoDados) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F0),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2D5016)),
        ),
      );
    }
    switch (_abaAtual) {
      case 0:
        return HomeScreen(
          compras: _comprasMesAtual,
          mesAno: _mesAno,
          onAdicionarCompra: _adicionarCompra,
          onAdicionarComprasNota: _adicionarComprasNota,
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
          onAdicionarProduto: _adicionarProdutoAcabando,
          onAtualizarProduto: _atualizarProdutoAcabando,
          onRemoverProduto: _removerProdutoAcabando,
        );
      case 2:
        return HistoricoScreen(historico: _historico);
      case 3:
        return EstoqueScreen(
          onRefresh: _carregarDados,
        );
      default:
        return HomeScreen(
          compras: _comprasMesAtual,
          mesAno: _mesAno,
          onAdicionarCompra: _adicionarCompra,
          onAdicionarComprasNota: _adicionarComprasNota,
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
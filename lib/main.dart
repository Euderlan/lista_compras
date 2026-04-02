import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'models/compra.dart';
import 'models/produto_acabando.dart';
import 'screens/home_screen.dart';
import 'screens/historico_screen.dart';
import 'screens/compras_futuras_screen.dart';
import 'screens/adicionar_compra_screen.dart';
import 'widgets/app_bottom_nav_bar.dart';

void main() {
  // Garante que o Flutter esteja inicializado antes de configurar orientacao
  WidgetsFlutterBinding.ensureInitialized();

  // Bloqueia orientacao para apenas retrato (comportamento padrao mobile)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ListaComprasApp());
}

// Widget raiz do aplicativo
class ListaComprasApp extends StatelessWidget {
  const ListaComprasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista Compras',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainNavigationWrapper(),
    );
  }
}

// Wrapper de navegacao que gerencia o estado global das compras
// e controla qual aba esta ativa na bottom nav bar
class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  // Aba atualmente selecionada (0: Home, 1: Compras Futuras, 2: Historico)
  int _abaAtual = 0;

  // Lista de compras do mes atual - inicia vazia
  final List<Compra> _comprasMesAtual = [];

  // Historico de meses anteriores - inicia vazio
  final List<ResumoMes> _historico = [];

  // Lista de produtos que estao acabando
  final List<ProdutoAcabando> _produtosAcabando = [];

  // Mes e ano exibidos no cabecalho
  final String _mesAno = _obterMesAno();

  // Retorna o mes e ano atual formatados em portugues
  static String _obterMesAno() {
    final agora = DateTime.now();
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Marco',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return '${meses[agora.month - 1]} ${agora.year}';
  }

  // Adiciona uma nova compra a lista do mes atual
  void _adicionarCompra(Compra compra) {
    setState(() => _comprasMesAtual.add(compra));
  }

  // Alterna o estado de "marcado" de uma compra pelo id
  void _toggleMarcado(String id) {
    setState(() {
      final index = _comprasMesAtual.indexWhere((c) => c.id == id);
      if (index != -1) {
        final compra = _comprasMesAtual[index];
        _comprasMesAtual[index] = compra.copyWith(marcado: !compra.marcado);
      }
    });
  }

  // Adiciona um produto a lista de acabando
  void _adicionarProdutoAcabando(ProdutoAcabando produto) {
    setState(() => _produtosAcabando.add(produto));
  }

  // Edita uma compra existente, substituindo por id
  void _editarCompra(Compra compraEditada) {
    setState(() {
      final index = _comprasMesAtual.indexWhere(
        (c) => c.id == compraEditada.id,
      );
      if (index != -1) {
        _comprasMesAtual[index] = compraEditada;
      }
    });
  }

  // Remove um produto da lista de acabando pelo id
  void _removerProdutoAcabando(String id) {
    setState(() => _produtosAcabando.removeWhere((p) => p.id == id));
  }

  // Troca a aba ativa na bottom navigation
  void _trocarAba(int index) {
    setState(() => _abaAtual = index);
  }

  // Retorna a tela correspondente a aba selecionada
  Widget _buildTela() {
    switch (_abaAtual) {
      case 0:
        return HomeScreen(
          compras: _comprasMesAtual,
          mesAno: _mesAno,
          onAdicionarCompra: _adicionarCompra,
          onMarcarAcabando: _adicionarProdutoAcabando,
          onEditarCompra: _editarCompra,
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
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A tela e construida dinamicamente conforme a aba ativa
      body: _buildTela(),

      // Barra de navegacao inferior compartilhada entre todas as telas
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _abaAtual,
        onTap: _trocarAba,
      ),
    );
  }
}

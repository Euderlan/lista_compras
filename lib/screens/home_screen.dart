import 'package:flutter/material.dart';
import '../models/compra.dart';
import '../models/produto_acabando.dart';
import '../theme/app_theme.dart';
import '../widgets/grafico_categoria.dart';
import '../widgets/card_compra.dart';
import 'adicionar_compra_screen.dart';

// Tela inicial com resumo de gastos do mes, grafico por categoria
// e lista das ultimas compras adicionadas
class HomeScreen extends StatelessWidget {
  // Lista de compras do mes atual (vazia inicialmente)
  final List<Compra> compras;

  // Mes e ano de referencia exibido no titulo
  final String mesAno;

  // Callback para adicionar nova compra
  final ValueChanged<Compra> onAdicionarCompra;

  // Callback para marcar produto como acabando
  final ValueChanged<ProdutoAcabando> onMarcarAcabando;

  // Callback para editar uma compra existente
  final ValueChanged<Compra> onEditarCompra;

  const HomeScreen({
    super.key,
    required this.compras,
    required this.mesAno,
    required this.onAdicionarCompra,
    required this.onMarcarAcabando,
    required this.onEditarCompra,
  });

  // Calcula o total gasto somando todas as compras
  double get _totalGasto => compras.fold(0, (soma, c) => soma + c.total);

  // Agrupa compras por categoria e calcula percentuais para o grafico
  List<DadosCategoria> get _dadosGrafico {
    if (compras.isEmpty) return [];

    // Acumula totais por categoria
    final Map<Categoria, double> totaisPorCategoria = {};
    for (final compra in compras) {
      totaisPorCategoria[compra.categoria] =
          (totaisPorCategoria[compra.categoria] ?? 0) + compra.total;
    }

    final total = _totalGasto;

    // Converte para lista de DadosCategoria com percentuais
    return totaisPorCategoria.entries.map((entry) {
      return DadosCategoria(
        categoria: entry.key,
        percentual: (entry.value / total) * 100,
        total: entry.value,
      );
    }).toList()..sort((a, b) => b.percentual.compareTo(a.percentual));
  }

  // Formata o total como moeda brasileira
  String _formatarTotal(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    return 'R\$ ${partes[0]},${partes[1]}';
  }

  // Abre a tela de adicionar compra
  Future<void> _abrirAdicionarCompra(BuildContext context) async {
    final novaCompra = await Navigator.push<Compra>(
      context,
      MaterialPageRoute(
        builder: (_) => const AdicionarCompraScreen(),
        fullscreenDialog: true,
      ),
    );

    if (novaCompra != null) {
      onAdicionarCompra(novaCompra);
    }
  }

  // Abre a tela para editar uma compra existente
  Future<void> _abrirEditarCompra(BuildContext context, Compra compra) async {
    final compraEditada = await Navigator.push<Compra>(
      context,
      MaterialPageRoute(
        builder: (_) => AdicionarCompraScreen(compraInicial: compra),
        fullscreenDialog: true,
      ),
    );

    if (compraEditada != null) {
      onEditarCompra(compraEditada);
    }
  }

  // Marca um produto como acabando
  void _marcarAcabando(Compra compra) {
    final produtoAcabando = ProdutoAcabando(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: compra.nome,
      categoria: compra.categoria,
      dataMarcado: DateTime.now(),
    );
    onMarcarAcabando(produtoAcabando);
  }

  @override
  Widget build(BuildContext context) {
    // Pega as 3 ultimas compras para exibir no resumo
    final ultimasCompras = compras.length > 3
        ? compras.sublist(compras.length - 3).reversed.toList()
        : compras.reversed.toList();

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Column(
        children: [
          // Header verde escuro com titulo
          _buildHeader(),

          // Corpo da tela com fundo claro
          Expanded(
            child: Container(
              color: AppColors.background,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card com total e grafico de pizza
                    _buildCardResumo(),

                    const SizedBox(height: 20),

                    // Secao de ultimas compras
                    if (ultimasCompras.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Ultimas Compras',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Lista das ultimas compras
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            children: ultimasCompras
                                .map(
                                  (c) => CardCompra(
                                    compra: c,
                                    onMarcarAcabando: () => _marcarAcabando(c),
                                    onEditar: () =>
                                        _abrirEditarCompra(context, c),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ] else
                      // Estado vazio - nenhuma compra adicionada ainda
                      _buildEstadoVazio(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header com menu, titulo do mes e botao de adicionar compra
  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Container(
        color: AppColors.primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Builder(
          builder: (context) => Row(
            children: [
              // Icone de menu hamburger
              const Icon(Icons.menu, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              // Titulo do mes atual
              Expanded(
                child: Text(
                  'Minha Compras - $mesAno',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Botao de adicionar compra
              GestureDetector(
                onTap: () => _abrirAdicionarCompra(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Card branco com total gasto e grafico de categorias
  Widget _buildCardResumo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Label "Total expendio"
          const Text(
            'Total expendio',
            style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 4),
          // Valor total formatado em destaque
          Text(
            _formatarTotal(_totalGasto),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          // Grafico de pizza ou placeholder vazio
          if (_dadosGrafico.isNotEmpty)
            GraficoCategoria(dados: _dadosGrafico, totalGasto: _totalGasto)
          else
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.searchBackground,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: const Center(
                child: Text(
                  'Sem\ndados',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Exibido quando nao ha compras registradas no mes
  Widget _buildEstadoVazio() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: AppColors.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nenhuma compra registrada',
              style: TextStyle(fontSize: 15, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Adicione sua primeira compra',
              style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

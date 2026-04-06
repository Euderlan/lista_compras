import 'package:flutter/material.dart';
import '../models/compra.dart';
import '../models/produto_acabando.dart';
import '../theme/app_theme.dart';
import '../widgets/grafico_categoria.dart';
import '../widgets/card_compra.dart';
import 'adicionar_compra_screen.dart';
import 'lista_completa_screen.dart';

// Tela inicial com resumo de gastos do mes, grafico por categoria
// e lista das ultimas compras adicionadas
class HomeScreen extends StatelessWidget {
  final List<Compra> compras;
  final String mesAno;
  final ValueChanged<Compra> onAdicionarCompra;
  final ValueChanged<ProdutoAcabando> onMarcarAcabando;
  final ValueChanged<Compra> onEditarCompra;
  final VoidCallback? onFecharMes;
  final VoidCallback? onLogout;
  final Function(String)? onRemoverCompra;

  const HomeScreen({
    super.key,
    required this.compras,
    required this.mesAno,
    required this.onAdicionarCompra,
    required this.onMarcarAcabando,
    required this.onEditarCompra,
    this.onFecharMes,
    this.onLogout,
    this.onRemoverCompra,
  });

  double get _totalGasto => compras.fold(0, (soma, c) => soma + c.total);

  List<DadosCategoria> get _dadosGrafico {
    if (compras.isEmpty) return [];
    final Map<Categoria, double> totaisPorCategoria = {};
    for (final compra in compras) {
      totaisPorCategoria[compra.categoria] =
          (totaisPorCategoria[compra.categoria] ?? 0) + compra.total;
    }
    final total = _totalGasto;
    return totaisPorCategoria.entries.map((entry) {
      return DadosCategoria(
        categoria: entry.key,
        percentual: (entry.value / total) * 100,
        total: entry.value,
      );
    }).toList()
      ..sort((a, b) => b.percentual.compareTo(a.percentual));
  }

  String _formatarTotal(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    return 'R\$ ${partes[0]},${partes[1]}';
  }

  Future<void> _abrirAdicionarCompra(BuildContext context) async {
    // Pode retornar Compra (manual) ou List<Compra> (via QR Code)
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdicionarCompraScreen(),
        fullscreenDialog: true,
      ),
    );

    if (resultado == null) return;

    if (resultado is Compra) {
      onAdicionarCompra(resultado);
    } else if (resultado is List<Compra>) {
      // Adiciona todas as compras da nota fiscal
      for (final compra in resultado) {
        onAdicionarCompra(compra);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${resultado.length} produto(s) adicionado(s) da nota fiscal'),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

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

  void _marcarAcabando(BuildContext context, Compra compra) {
    final produtoAcabando = ProdutoAcabando(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: compra.nome,
      categoria: compra.categoria,
      dataMarcado: DateTime.now(),
    );
    onMarcarAcabando(produtoAcabando);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${compra.nome}" adicionado às compras futuras'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Abre dialogo de confirmacao para fechar o mes
  void _confirmarFecharMes(BuildContext context) {
    if (compras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma compra para fechar'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fechar Mês'),
        content: Text(
          'Deseja fechar o mês de $mesAno?\n\nTotal: ${_formatarTotal(_totalGasto)}\nCompras: ${compras.length} item(s)\n\nEssa ação moverá as compras para o histórico.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onFecharMes?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
            ),
            child: const Text('Fechar Mês'),
          ),
        ],
      ),
    );
  }

  // Abre a tela com lista completa de compras
  void _verTodasCompras(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListaCompletaScreen(
          compras: compras,
          onMarcarAcabando: onMarcarAcabando,
          onEditarCompra: onEditarCompra,
        ),
      ),
    );
  }

  // Drawer lateral com informacoes e acoes do mes
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.cardBackground,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecalho do drawer
            Container(
              width: double.infinity,
              color: AppColors.primaryDark,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Lista de Compras',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mesAno,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Resumo rapido
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RESUMO DO MÊS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTertiary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DrawerInfoRow(
                    icone: Icons.receipt_long_outlined,
                    label: 'Total de compras',
                    valor: '${compras.length} item(s)',
                  ),
                  const SizedBox(height: 8),
                  _DrawerInfoRow(
                    icone: Icons.attach_money,
                    label: 'Total gasto',
                    valor: _formatarTotal(_totalGasto),
                  ),
                ],
              ),
            ),

            const Divider(height: 32, indent: 20, endIndent: 20),

            // Acoes
            ListTile(
              leading: const Icon(Icons.add_circle_outline,
                  color: AppColors.accent),
              title: const Text('Adicionar Compra'),
              onTap: () {
                Navigator.pop(context);
                _abrirAdicionarCompra(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt_outlined,
                  color: AppColors.accent),
              title: const Text('Ver Todas as Compras'),
              onTap: () {
                Navigator.pop(context);
                _verTodasCompras(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline,
                  color: AppColors.primaryDark),
              title: const Text('Fechar Mês'),
              subtitle: const Text('Mover para o histórico'),
              onTap: () {
                Navigator.pop(context);
                _confirmarFecharMes(context);
              },
            ),


            const Divider(indent: 20, endIndent: 20),

            // Botao de sair
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Sair',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                onLogout?.call();
              },
            ),
            const Spacer(),

            // Versao
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Lista Compras v1.0',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ultimasCompras = compras.length > 3
        ? compras.sublist(compras.length - 3).reversed.toList()
        : compras.reversed.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: false,
        // Icone hamburguer abre o drawer automaticamente com leading padrao
        title: Text(
          'Minhas Compras - $mesAno',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Botao de fechar mes
          IconButton(
            icon: const Icon(Icons.lock_outline, color: Colors.white),
            tooltip: 'Fechar Mês',
            onPressed: () => _confirmarFecharMes(context),
          ),
          // Botao de adicionar compra
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Adicionar Compra',
            onPressed: () => _abrirAdicionarCompra(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card com total e grafico de pizza
            _buildCardResumo(),

            const SizedBox(height: 20),

            // Secao de ultimas compras
            if (ultimasCompras.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Últimas Compras',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    // Botao "Ver todas" visivel apenas quando ha mais de 3 compras
                    if (compras.length > 3)
                      TextButton(
                        onPressed: () => _verTodasCompras(context),
                        child: const Text(
                          'Ver todas',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
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
                            onMarcarAcabando: () =>
                                _marcarAcabando(context, c),
                            onEditar: () => _abrirEditarCompra(context, c),
                            onRemover: onRemoverCompra != null
                                ? () => onRemoverCompra!(c.id)
                                : null,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),

              // Botao ver todas abaixo da lista (sempre visivel se ha compras)
              if (compras.length > 3)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _verTodasCompras(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Ver todas as compras',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
            ] else
              _buildEstadoVazio(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

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
          const Text(
            'Total gasto no mês',
            style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 4),
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
                  style:
                      TextStyle(color: AppColors.textTertiary, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEstadoVazio() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nenhuma compra registrada',
              style: TextStyle(fontSize: 15, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Toque em + para adicionar sua primeira compra',
              style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Row de informacao dentro do drawer
class _DrawerInfoRow extends StatelessWidget {
  final IconData icone;
  final String label;
  final String valor;

  const _DrawerInfoRow({
    required this.icone,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, size: 18, color: AppColors.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
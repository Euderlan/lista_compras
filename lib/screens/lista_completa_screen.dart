import 'package:flutter/material.dart';
import '../models/compra.dart';
import '../models/produto_acabando.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/card_compra.dart';
import 'adicionar_compra_screen.dart';

// Tela que exibe todas as compras do mes com filtro por categoria
class ListaCompletaScreen extends StatefulWidget {
  final List<Compra> compras;
  final ValueChanged<ProdutoAcabando> onMarcarAcabando;
  final ValueChanged<Compra> onEditarCompra;
  final Function(String)? onRemoverCompra;

  const ListaCompletaScreen({
    super.key,
    required this.compras,
    required this.onMarcarAcabando,
    required this.onEditarCompra,
    this.onRemoverCompra,
  });

  @override
  State<ListaCompletaScreen> createState() => _ListaCompletaScreenState();
}

class _ListaCompletaScreenState extends State<ListaCompletaScreen> {
  // Categoria selecionada para filtro (null = todas)
  Categoria? _filtroCategoria;

  // Retorna as compras filtradas pela categoria selecionada
  List<Compra> get _comprasFiltradas {
    if (_filtroCategoria == null) return widget.compras.reversed.toList();
    return widget.compras
        .where((c) => c.categoria == _filtroCategoria)
        .toList()
        .reversed
        .toList();
  }

  // Total das compras filtradas
  double get _totalFiltrado =>
      _comprasFiltradas.fold(0, (soma, c) => soma + c.total);

  String _formatarValor(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    return 'R\$ ${partes[0]},${partes[1]}';
  }

  // Abre tela de edicao da compra
  Future<void> _editarCompra(Compra compra) async {
    final compraEditada = await Navigator.push<Compra>(
      context,
      MaterialPageRoute(
        builder: (_) => AdicionarCompraScreen(compraInicial: compra),
        fullscreenDialog: true,
      ),
    );
    if (compraEditada != null) {
      widget.onEditarCompra(compraEditada);
    }
  }

  // Marca produto como acabando com feedback visual
  void _marcarAcabando(Compra compra) {
    final produto = ProdutoAcabando(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: compra.nome,
      categoria: compra.categoria,
      dataMarcado: DateTime.now(),
    );
    widget.onMarcarAcabando(produto);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${compra.nome}" marcado como acabando'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(titulo: 'Todas as Compras'),
      body: Column(
        children: [
          // Filtros de categoria
          _buildFiltros(),

          // Resumo do total filtrado
          _buildResumoTotal(),

          // Lista de compras
          Expanded(
            child: _comprasFiltradas.isEmpty
                ? _buildEstadoVazio()
                : _buildLista(),
          ),
        ],
      ),
    );
  }

  // Chips de filtro por categoria
  Widget _buildFiltros() {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Chip "Todas"
            _ChipFiltro(
              label: 'Todas',
              selecionado: _filtroCategoria == null,
              onTap: () => setState(() => _filtroCategoria = null),
            ),
            const SizedBox(width: 8),
            // Chips por categoria
            ...Categoria.values.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _ChipFiltro(
                    label: cat.nome,
                    selecionado: _filtroCategoria == cat,
                    onTap: () => setState(() => _filtroCategoria = cat),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // Barra com total das compras filtradas
  Widget _buildResumoTotal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_comprasFiltradas.length} item(s)',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          Text(
            _formatarValor(_totalFiltrado),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // Lista agrupada com todos os itens
  Widget _buildLista() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: _comprasFiltradas.length,
      itemBuilder: (context, index) {
        final compra = _comprasFiltradas[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CardCompra(
                compra: compra,
                onMarcarAcabando: () => _marcarAcabando(compra),
                onEditar: () => _editarCompra(compra),
                onRemover: widget.onRemoverCompra != null
                    ? () => widget.onRemoverCompra!(compra.id)
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEstadoVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 48,
            color: AppColors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'Nenhuma compra encontrada',
            style: TextStyle(fontSize: 15, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

// Chip de filtro individual
class _ChipFiltro extends StatelessWidget {
  final String label;
  final bool selecionado;
  final VoidCallback onTap;

  const _ChipFiltro({
    required this.label,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selecionado ? AppColors.primaryDark : AppColors.searchBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selecionado ? AppColors.primaryDark : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selecionado ? FontWeight.w600 : FontWeight.w400,
            color: selecionado ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
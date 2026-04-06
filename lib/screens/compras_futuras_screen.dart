import 'package:flutter/material.dart';
import '../models/compra.dart';
import '../models/produto_acabando.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import 'adicionar_compra_screen.dart';

// Tela de compras futuras baseada nos produtos que estao acabando
class ComprasFuturasScreen extends StatelessWidget {
  final List<ProdutoAcabando> produtosAcabando;
  final ValueChanged<Compra> onAdicionarCompra;
  final VoidCallback? onRemoverProduto;

  const ComprasFuturasScreen({
    super.key,
    required this.produtosAcabando,
    required this.onAdicionarCompra,
    this.onRemoverProduto,
  });

  Future<void> _adicionarCompraFutura(
      BuildContext context, ProdutoAcabando produto) async {
    final novaCompra = await Navigator.push<Compra>(
      context,
      MaterialPageRoute(
        builder: (_) => AdicionarCompraScreen(produtoInicial: produto),
        fullscreenDialog: true,
      ),
    );

    if (novaCompra != null) {
      onAdicionarCompra(novaCompra);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${novaCompra.nome}" adicionado às compras do mês'),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _adicionarCompraManual(BuildContext context) async {
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

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes';
  }

  // Icone por categoria
  IconData _iconCategoria(Categoria categoria) {
    switch (categoria) {
      case Categoria.mercado:
        return Icons.shopping_basket_outlined;
      case Categoria.higiene:
        return Icons.soap_outlined;
      case Categoria.hortifruti:
        return Icons.local_florist_outlined;
      case Categoria.outros:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        titulo: 'Compras Futuras',
        actions: [
          TextButton(
            onPressed: () => _adicionarCompraManual(context),
            child: const Text(
              'Adicionar',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: produtosAcabando.isEmpty
          ? _buildEstadoVazio()
          : _buildListaProdutos(context),
    );
  }

  Widget _buildListaProdutos(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabecalho informativo
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: AppColors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${produtosAcabando.length} produto(s) precisando ser reabastecido(s)',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista de produtos
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: produtosAcabando.length,
            itemBuilder: (context, index) {
              final produto = produtosAcabando[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Icone da categoria
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.searchBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _iconCategoria(produto.categoria),
                          size: 20,
                          color: AppColors.primaryMedium,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Informacoes do produto
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              produto.nome,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  produto.categoria.nome,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 10,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Marcado em ${_formatarData(produto.dataMarcado)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Botao de comprar
                      ElevatedButton(
                        onPressed: () =>
                            _adicionarCompraFutura(context, produto),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Comprar'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEstadoVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.playlist_add_outlined,
            size: 56,
            color: AppColors.textTertiary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'Nenhuma compra futura planejada',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Segure um item na tela inicial para\nmarcá-lo como acabando',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/compra.dart';
import '../models/produto_acabando.dart';
import '../theme/app_theme.dart';
import 'adicionar_compra_screen.dart';

// Tela de compras futuras baseada nos produtos que estao acabando
class ComprasFuturasScreen extends StatelessWidget {
  final List<ProdutoAcabando> produtosAcabando;
  final ValueChanged<Compra> onAdicionarCompra;

  const ComprasFuturasScreen({
    super.key,
    required this.produtosAcabando,
    required this.onAdicionarCompra,
  });

  // Abre a tela de adicionar compra com o produto pre-selecionado
  Future<void> _adicionarCompraFutura(BuildContext context, ProdutoAcabando produto) async {
    final novaCompra = await Navigator.push<Compra>(
      context,
      MaterialPageRoute(
        builder: (_) => AdicionarCompraScreen(
          produtoInicial: produto,
        ),
        fullscreenDialog: true,
      ),
    );

    if (novaCompra != null) {
      onAdicionarCompra(novaCompra);
    }
  }

  // Abre a tela de adicionar compra sem pre-selecao
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Compras Futuras',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _adicionarCompraManual(context),
            child: const Text(
              'Adicionar',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: produtosAcabando.length,
      itemBuilder: (context, index) {
        final produto = produtosAcabando[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(produto.nome),
            subtitle: Text('${produto.categoria.nome} - ${produto.dataMarcado.day}/${produto.dataMarcado.month}'),
            trailing: ElevatedButton(
              onPressed: () => _adicionarCompraFutura(context, produto),
              child: const Text('Comprar'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEstadoVazio() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 48, color: AppColors.textTertiary),
          SizedBox(height: 12),
          Text(
            'Nenhuma compra futura planejada',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Adicione produtos acabando primeiro',
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
import 'package:flutter/material.dart';
import '../models/compra.dart';
import '../models/produto_acabando.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import 'adicionar_produto_futuro_screen.dart';
import '../services/whatsapp_service.dart';

class ComprasFuturasScreen extends StatefulWidget {
  final List<ProdutoAcabando> produtosAcabando;
  final ValueChanged<Compra> onAdicionarCompra;
  final Function(ProdutoAcabando)? onAdicionarProduto;
  final Function(ProdutoAcabando)? onAtualizarProduto;
  final Function(String)? onRemoverProduto;

  const ComprasFuturasScreen({
    super.key,
    required this.produtosAcabando,
    required this.onAdicionarCompra,
    this.onAdicionarProduto,
    this.onAtualizarProduto,
    this.onRemoverProduto,
  });

  @override
  State<ComprasFuturasScreen> createState() => _ComprasFuturasScreenState();
}

class _ComprasFuturasScreenState extends State<ComprasFuturasScreen> {
  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes';
  }

  String _formatarPreco(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    return 'R\$ ${partes[0]},${partes[1]}';
  }

  double get _totalEstimado {
    return widget.produtosAcabando
        .where((p) => p.precoUltimo != null)
        .fold(0.0, (soma, p) => soma + p.precoUltimo!);
  }

  IconData _iconCategoria(Categoria categoria) {
    switch (categoria) {
      case Categoria.mercado: return Icons.shopping_basket_outlined;
      case Categoria.higiene: return Icons.soap_outlined;
      case Categoria.hortifruti: return Icons.local_florist_outlined;
      case Categoria.outros: return Icons.category_outlined;
    }
  }

  Future<void> _adicionarManual() async {
    final novo = await Navigator.push<ProdutoAcabando>(
      context,
      MaterialPageRoute(
        builder: (_) => const AdicionarProdutoFuturoScreen(),
        fullscreenDialog: true,
      ),
    );

    if (novo != null && widget.onAdicionarProduto != null) {
      widget.onAdicionarProduto!(novo);
    }
  }

  Future<void> _editarProduto(ProdutoAcabando produto) async {
    final editado = await Navigator.push<ProdutoAcabando>(
      context,
      MaterialPageRoute(
        builder: (_) => AdicionarProdutoFuturoScreen(produtoInicial: produto),
        fullscreenDialog: true,
      ),
    );

    if (editado != null && widget.onAtualizarProduto != null) {
      widget.onAtualizarProduto!(editado);
    }
  }

  void _confirmarRemover(ProdutoAcabando produto) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover produto?'),
        content: Text('Deseja remover "${produto.nome}" da lista futura?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onRemoverProduto?.call(produto.id);
            },
            child: const Text('Remover',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Quando o usuário toca "Comprar" — abre tela de adicionar compra real
  Future<void> _marcarComoComprado(ProdutoAcabando produto) async {
    // Monta uma Compra básica com o que sabemos
    final compraBase = Compra(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: produto.nome,
      preco: produto.precoUltimo ?? 0.0,
      quantidade: 1,
      categoria: produto.categoria,
      loja: 'Sem loja',
      data: DateTime.now(),
      marcado: false,
    );

    widget.onAdicionarCompra(compraBase);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${produto.nome}" adicionado às compras do mês'),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final temTotal = widget.produtosAcabando.any((p) => p.precoUltimo != null);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        titulo: 'Compras Futuras',
        actions: [
          IconButton(
            icon: const Icon(
            Icons.share,
            color: Colors.white,
          ),
          tooltip: 'Enviar para WhatsApp',
          onPressed: widget.produtosAcabando.isEmpty
              ? null
              : () => WhatsAppService.compartilharLista(
                    widget.produtosAcabando,
                  ),
        ),
          TextButton(
            onPressed: _adicionarManual,
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
      body: widget.produtosAcabando.isEmpty
          ? _buildEstadoVazio()
          : _buildConteudo(temTotal),
    );
  }

  Widget _buildConteudo(bool temTotal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho com contagem e total estimado
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  size: 16, color: AppColors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.produtosAcabando.length} produto(s) para comprar',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (temTotal) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total estimado',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.accent),
                    ),
                    Text(
                      _formatarPreco(_totalEstimado),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Lista
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: widget.produtosAcabando.length,
            itemBuilder: (context, index) {
              final produto = widget.produtosAcabando[index];
              return _buildCardProduto(produto);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCardProduto(ProdutoAcabando produto) {
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
            // Ícone categoria
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

            // Informações
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
                      if (produto.precoUltimo != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _formatarPreco(produto.precoUltimo!),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
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

            // Ações
            Column(
              children: [
                // Botão comprar
                ElevatedButton(
                  onPressed: () => _marcarComoComprado(produto),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('Comprar'),
                ),
                const SizedBox(height: 4),
                // Menu editar/remover
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _editarProduto(produto),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _confirmarRemover(produto),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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
            'Toque em "Adicionar" ou segure um\nitem na tela inicial para marcar como acabando',
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
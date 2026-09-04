import 'package:flutter/material.dart';
import '../models/produto_estoque.dart';
import '../theme/app_theme.dart';

class CardEstoque extends StatelessWidget {
  final ProdutoEstoque produto;
  final double totalGasto;
  final VoidCallback onEditar;
  final VoidCallback onRemover;
  final VoidCallback onMerge;

  const CardEstoque({
    Key? key,
    required this.produto,
    required this.totalGasto,
    required this.onEditar,
    required this.onRemover,
    required this.onMerge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(produto.nome, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        subtitle: Text('Qty: ${produto.quantidade} ${produto.unidade}\nTotal: R\$ ${totalGasto.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEditar();
                break;
              case 'remove':
                onRemover();
                break;
              case 'merge':
                onMerge();
                break;
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Editar')),
            PopupMenuItem(value: 'remove', child: Text('Remover')),
            PopupMenuItem(value: 'merge', child: Text('Mesclar')),
          ],
        ),
      ),
    );
  }
}

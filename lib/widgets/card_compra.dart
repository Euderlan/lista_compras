import 'package:flutter/material.dart';
import '../models/compra.dart';
import '../theme/app_theme.dart';

// Card de item de compra exibido na lista e no resumo da home
class CardCompra extends StatelessWidget {
  final Compra compra;
  final bool exibirCheckbox;
  final ValueChanged<bool?>? onCheckChanged;
  final VoidCallback? onMarcarAcabando;
  final VoidCallback? onEditar;

  const CardCompra({
    super.key,
    required this.compra,
    this.exibirCheckbox = false,
    this.onCheckChanged,
    this.onMarcarAcabando,
    this.onEditar,
  });

  // Retorna o icone correspondente a categoria
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

  // Formata o preco para exibicao em reais
  String _formatarPreco(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // Formata a data no padrao dia/mes
  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onMarcarAcabando != null
          ? () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Marcar como acabando?'),
                  content: Text(
                    'Deseja marcar "${compra.nome}" como produto que está acabando?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onMarcarAcabando!();
                      },
                      child: const Text('Marcar'),
                    ),
                  ],
                ),
              );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: Row(
          children: [
            // Checkbox ou icone da categoria
            if (exibirCheckbox)
              Checkbox(
                value: compra.marcado,
                onChanged: onCheckChanged,
                activeColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(color: AppColors.border, width: 1.5),
              )
            else
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.searchBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _iconCategoria(compra.categoria),
                  size: 18,
                  color: AppColors.primaryMedium,
                ),
              ),

            const SizedBox(width: 12),

            // Informacoes do produto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome do produto
                  Text(
                    compra.nome,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Preco unitario
                  Text(
                    _formatarPreco(compra.preco),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Categoria e loja
                  Text(
                    '${compra.categoria.nome} / ${compra.loja}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Coluna com total e data
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Total do item
                Text(
                  'R\$ ${compra.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                // Quantidade
                Text(
                  '${compra.quantidade} un',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                // Data da compra
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 10,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      _formatarData(compra.data),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Botao oculto para editar e marcar acabando
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                size: 20,
                color: AppColors.textTertiary,
              ),
              onSelected: (value) {
                if (value == 'editar' && onEditar != null) {
                  onEditar!();
                } else if (value == 'acabando' && onMarcarAcabando != null) {
                  onMarcarAcabando!();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'editar', child: Text('Editar')),
                const PopupMenuItem(
                  value: 'acabando',
                  child: Text('Marcar como acabando'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

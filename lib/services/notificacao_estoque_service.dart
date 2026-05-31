import 'package:flutter/material.dart';
import '../models/produto_estoque.dart';
import '../models/produto_acabando.dart';
import 'produto_estoque_service.dart';
import '../models/compra.dart';

// Serviço que gerencia o fluxo de notificações de estoque
// Não usa push notifications — usa diálogos ao abrir o app
class NotificacaoEstoqueService {
  final _estoqueService = ProdutoEstoqueService();

  // Verifica e exibe notificações pendentes sequencialmente
  // Chame este método no initState do MainNavigationWrapper
  Future<void> verificarENotificar({
    required BuildContext context,
    required String mesAno,
    required Function(ProdutoAcabando) onProdutoAcabou,
  }) async {
    try {
      final produtos = await _estoqueService.buscarProdutosParaNotificar(mesAno);
      if (produtos.isEmpty) return;
      if (!context.mounted) return;

      // Mostra notificações uma por vez em sequência
      for (final produto in produtos) {
        if (!context.mounted) break;
        await _mostrarDialogo(
          context: context,
          produto: produto,
          mesAno: mesAno,
          onProdutoAcabou: onProdutoAcabou,
        );
      }
    } catch (_) {}
  }

  Future<void> _mostrarDialogo({
    required BuildContext context,
    required ProdutoEstoque produto,
    required String mesAno,
    required Function(ProdutoAcabando) onProdutoAcabou,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DialogoEstoque(
        produto: produto,
        onAcabou: () async {
          Navigator.pop(ctx);
          await _estoqueService.marcarAcabou(produto.id);

          // Envia para tela de compras futuras
          final produtoAcabando = ProdutoAcabando(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            nome: produto.nome,
            categoria: produto.categoria,
            dataMarcado: DateTime.now(),
          );
          onProdutoAcabou(produtoAcabando);
        },
        onAindaNao: () async {
          Navigator.pop(ctx);
          // Calcula dias para próxima notificação baseado no peso e quantidade
          final dias = _calcularDiasSnooze(produto);
          await _estoqueService.adiarNotificacao(produto.id, dias);
        },
        onTresDias: () async {
          Navigator.pop(ctx);
          await _estoqueService.adiarTresDias(produto.id);
        },
      ),
    );
  }

  // Calcula snooze dinâmico para "ainda não"
  // Quanto maior o peso/quantidade, mais dias de snooze
  int _calcularDiasSnooze(ProdutoEstoque produto) {
    final pesoTotal = produto.quantidade * produto.pesoUnitario;
    if (pesoTotal < 500) return 2;
    if (pesoTotal < 1000) return 3;
    if (pesoTotal < 3000) return 5;
    if (pesoTotal < 6000) return 7;
    return 10;
  }
}

class _DialogoEstoque extends StatelessWidget {
  final ProdutoEstoque produto;
  final VoidCallback onAcabou;
  final VoidCallback onAindaNao;
  final VoidCallback onTresDias;

  const _DialogoEstoque({
    required this.produto,
    required this.onAcabou,
    required this.onAindaNao,
    required this.onTresDias,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.inventory_2_outlined, color: Color(0xFF2D5016)),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Verificação de Estoque',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'O produto abaixo já acabou?',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE8E8E0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto.nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${produto.quantidade % 1 == 0 ? produto.quantidade.toInt() : produto.quantidade} '
                  '${produto.unidade} — ${produto.categoria.nome}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: onAcabou,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5016),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Acabou',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 6),
              OutlinedButton(
                onPressed: onTresDias,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2D5016)),
                  foregroundColor: const Color(0xFF2D5016),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Em 3 dias',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: onAindaNao,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF999999),
                ),
                child: const Text('Ainda não acabou'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
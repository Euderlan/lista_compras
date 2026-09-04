// Tela de Estoque Virtual - exibe produtos em estoque persistentes
import 'package:flutter/material.dart';
import '../models/produto_estoque.dart';
import '../services/produto_estoque_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/card_estoque.dart';

class EstoqueScreen extends StatefulWidget {
  // Callback to refresh data on parent if needed (e.g., after edit/delete)
  final VoidCallback? onRefresh;

  const EstoqueScreen({Key? key, this.onRefresh}) : super(key: key);

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  final _service = ProdutoEstoqueService();
  List<ProdutoEstoque> _estoque = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarEstoque();
  }

  Future<void> _carregarEstoque() async {
    try {
      final itens = await _service.buscarTodosProdutos();
      setState(() {
        _estoque = itens;
        _carregando = false;
      });
    } catch (e) {
      // Ensure UI stops loading and display error
      if (mounted) {
        setState(() => _carregando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar estoque: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _recarregar() async {
    await _carregarEstoque();
    widget.onRefresh?.call();
  }

  void _exibirDialogEdicao(ProdutoEstoque produto) async {
    final nomeCtrl = TextEditingController(text: produto.nome);
    final quantidadeCtrl = TextEditingController(text: produto.quantidade.toString());
    final precoCtrl = TextEditingController(text: produto.precoUnitario.toStringAsFixed(2));
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Produto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeCtrl,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: quantidadeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade'),
            ),
            TextField(
              controller: precoCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Preço unitário'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final novaQuant = double.tryParse(quantidadeCtrl.text) ?? produto.quantidade;
              final novoPreco = double.tryParse(precoCtrl.text.replaceAll(',', '.')) ?? produto.precoUnitario;
              final atualizado = ProdutoEstoque(
                id: produto.id,
                usuarioId: produto.usuarioId,
                nome: nomeCtrl.text.trim().isEmpty ? produto.nome : nomeCtrl.text.trim(),
                categoria: produto.categoria,
                quantidade: novaQuant,
                unidade: produto.unidade,
                pesoUnitario: produto.pesoUnitario,
                precoUnitario: novoPreco,
                dataCompra: produto.dataCompra,
                mesAno: produto.mesAno,
                acabou: produto.acabou,
                proximaNotificacao: produto.proximaNotificacao,
                diasSnooze: produto.diasSnooze,
              );
              await _service.atualizarProduto(atualizado);
              Navigator.pop(context, true);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (result == true) {
      await _recarregar();
    }
  }

  void _confirmarRemocao(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Remover Produto'),
        content: const Text('Tem certeza que deseja remover este produto do estoque?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Remover')),
        ],
      ),
    );
    if (confirmar == true) {
      await _service.removerProduto(id);
      await _recarregar();
    }
  }

  void _mergearProdutos(ProdutoEstoque a) async {
    // Seleciona outro produto para mesclar
    final outros = _estoque.where((p) => p.id != a.id).toList();
    if (outros.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nenhum outro produto para mesclar.')));
      return;
    }
    ProdutoEstoque? selecionado;
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Mesclar com'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: outros.length,
            itemBuilder: (ctx, i) {
              final p = outros[i];
              return ListTile(
                title: Text(p.nome),
                subtitle: Text('Qty: ${p.quantidade}, Preço: R\$ ${p.precoUnitario.toStringAsFixed(2)}'),
                onTap: () {
                  selecionado = p;
                  Navigator.pop(c);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
        ],
      ),
    );
    if (selecionado == null) return;
    // Calcula novos valores ponderados
    final totalQtd = a.quantidade + selecionado!.quantidade;
    final totalPreco = (a.precoUnitario * a.quantidade) + (selecionado!.precoUnitario * selecionado!.quantidade);
    final novoPreco = totalPreco / totalQtd;
    final produtoMesclado = ProdutoEstoque(
      id: a.id,
      usuarioId: a.usuarioId,
      nome: a.nome,
      categoria: a.categoria,
      quantidade: totalQtd,
      unidade: a.unidade,
      pesoUnitario: a.pesoUnitario,
      precoUnitario: novoPreco,
      dataCompra: a.dataCompra,
      mesAno: a.mesAno,
      acabou: a.acabou,
      proximaNotificacao: a.proximaNotificacao,
      diasSnooze: a.diasSnooze,
    );
    await _service.atualizarProduto(produtoMesclado);
    await _service.removerProduto(selecionado!.id);
    await _recarregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(titulo: 'Estoque'),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D5016)))
          : _estoque.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.inventory, size: 56, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Estoque vazio', style: TextStyle(fontSize: 15, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _estoque.length,
                  itemBuilder: (context, index) {
                    final p = _estoque[index];
                    final totalGasto = p.precoUnitario * p.quantidade;
                    return CardEstoque(
                      produto: p,
                      totalGasto: totalGasto,
                      onEditar: () => _exibirDialogEdicao(p),
                      onRemover: () => _confirmarRemocao(p.id),
                      onMerge: () => _mergearProdutos(p),
                    );
                  },
                ),
    );
  }
}

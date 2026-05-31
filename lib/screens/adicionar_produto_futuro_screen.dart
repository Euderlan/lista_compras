import 'package:flutter/material.dart';
import '../models/compra.dart';
import '../models/produto_acabando.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';

// Tela para adicionar produto na lista de compras futuras manualmente
// Preço e loja são opcionais pois o usuário pode não saber ainda
class AdicionarProdutoFuturoScreen extends StatefulWidget {
  final ProdutoAcabando? produtoInicial;

  const AdicionarProdutoFuturoScreen({
    super.key,
    this.produtoInicial,
  });

  @override
  State<AdicionarProdutoFuturoScreen> createState() =>
      _AdicionarProdutoFuturoScreenState();
}

class _AdicionarProdutoFuturoScreenState
    extends State<AdicionarProdutoFuturoScreen> {
  final _nomeController = TextEditingController();
  final _precoController = TextEditingController();

  Categoria _categoriaSelecionada = Categoria.mercado;
  bool _categoriaExpandida = false;

  @override
  void initState() {
    super.initState();
    if (widget.produtoInicial != null) {
      final p = widget.produtoInicial!;
      _nomeController.text = p.nome;
      _categoriaSelecionada = p.categoria;
      if (p.precoUltimo != null) {
        _precoController.text =
            p.precoUltimo!.toStringAsFixed(2).replaceAll('.', ',');
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  void _salvar() {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Informe o nome do produto'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    double? preco;
    final precoTxt = _precoController.text.trim().replaceAll(',', '.');
    if (precoTxt.isNotEmpty) {
      preco = double.tryParse(precoTxt);
      if (preco != null && preco <= 0) {
        preco = null;
      }
    }

    final produto = ProdutoAcabando(
      id: widget.produtoInicial?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome,
      categoria: _categoriaSelecionada,
      dataMarcado: widget.produtoInicial?.dataMarcado ?? DateTime.now(),
      precoUltimo: preco,
    );

    Navigator.pop(context, produto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderModal(
        titulo: widget.produtoInicial != null
            ? 'Editar Produto'
            : 'Adicionar Produto Futuro',
        onCancelar: () => Navigator.pop(context),
        onSalvar: _salvar,
        labelSalvar: widget.produtoInicial != null ? 'Salvar' : 'Adicionar',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Card com campos
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  // Nome
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 90,
                          child: Text(
                            'Produto',
                            style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textPrimary),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _nomeController,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary),
                            decoration: const InputDecoration(
                              hintText: 'Ex: Arroz, Leite...',
                              hintStyle: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 15),
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: AppColors.border),

                  // Preço (opcional)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 90,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Preço (R\$)',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textPrimary),
                              ),
                              Text(
                                'opcional',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _precoController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary),
                            decoration: const InputDecoration(
                              hintText: '0,00',
                              hintStyle: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 15),
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: AppColors.border),

                  // Categoria
                  InkWell(
                    onTap: () => setState(
                        () => _categoriaExpandida = !_categoriaExpandida),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const Text(
                            'Categoria',
                            style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textPrimary),
                          ),
                          const Spacer(),
                          Text(
                            _categoriaSelecionada.nome,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          AnimatedRotation(
                            turns: _categoriaExpandida ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(
                              Icons.expand_more,
                              size: 20,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Dropdown categoria
            if (_categoriaExpandida) ...[
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: Categoria.values.map((cat) {
                    final sel = cat == _categoriaSelecionada;
                    return ListTile(
                      title: Text(
                        cat.nome,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              sel ? FontWeight.w600 : FontWeight.w400,
                          color: sel
                              ? AppColors.accent
                              : AppColors.textPrimary,
                        ),
                      ),
                      trailing: sel
                          ? const Icon(Icons.check, color: AppColors.accent)
                          : null,
                      onTap: () => setState(() {
                        _categoriaSelecionada = cat;
                        _categoriaExpandida = false;
                      }),
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Informativo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: AppColors.accent),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Preço é opcional. Você pode preencher depois quando souber onde comprar.',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botão salvar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.produtoInicial != null
                        ? 'Salvar Alterações'
                        : 'Adicionar à Lista Futura',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
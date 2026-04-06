import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/compra.dart';
import '../models/produto_acabando.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import 'qr_scanner_screen.dart';

// Tela modal para adicionar ou editar uma compra
class AdicionarCompraScreen extends StatefulWidget {
  final Compra? compraInicial;
  final ProdutoAcabando? produtoInicial;

  const AdicionarCompraScreen({
    super.key,
    this.compraInicial,
    this.produtoInicial,
  });

  @override
  State<AdicionarCompraScreen> createState() => _AdicionarCompraScreenState();
}

class _AdicionarCompraScreenState extends State<AdicionarCompraScreen> {
  final _nomeController = TextEditingController();
  final _precoController = TextEditingController();
  final _lojaController = TextEditingController();

  int _quantidade = 1;
  Categoria _categoriaSelecionada = Categoria.mercado;
  DateTime _dataSelecionada = DateTime.now();
  bool _categoriaExpandida = false;

  @override
  void initState() {
    super.initState();

    if (widget.compraInicial != null) {
      final compra = widget.compraInicial!;
      _nomeController.text = compra.nome;
      _precoController.text =
          compra.preco.toStringAsFixed(2).replaceAll('.', ',');
      _lojaController.text = compra.loja == 'Sem loja' ? '' : compra.loja;
      _quantidade = compra.quantidade;
      _categoriaSelecionada = compra.categoria;
      _dataSelecionada = compra.data;
    } else if (widget.produtoInicial != null) {
      _nomeController.text = widget.produtoInicial!.nome;
      _categoriaSelecionada = widget.produtoInicial!.categoria;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    _lojaController.dispose();
    super.dispose();
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  Future<void> _selecionarData() async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accent,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (dataSelecionada != null) {
      setState(() => _dataSelecionada = dataSelecionada);
    }
  }

  void _salvarCompra() {
    final nome = _nomeController.text.trim();
    final precoTexto = _precoController.text.trim().replaceAll(',', '.');
    final loja = _lojaController.text.trim();

    if (nome.isEmpty) {
      _mostrarErro('Informe o nome do produto');
      return;
    }

    final preco = double.tryParse(precoTexto);
    if (preco == null || preco <= 0) {
      _mostrarErro('Informe um preço válido');
      return;
    }

    final novaCompra = Compra(
      id: widget.compraInicial?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome,
      preco: preco,
      quantidade: _quantidade,
      categoria: _categoriaSelecionada,
      loja: loja.isEmpty ? 'Sem loja' : loja,
      data: _dataSelecionada,
      marcado: widget.compraInicial?.marcado ?? false,
    );

    Navigator.pop(context, novaCompra);
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _escanearQRCode() async {
    final resultado = await Navigator.push<List<Compra>>(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );
    // Retorna a lista de compras da nota para quem chamou esta tela
    if (resultado != null && resultado.isNotEmpty && mounted) {
      Navigator.pop(context, resultado);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderModal(
        titulo: widget.compraInicial != null
            ? 'Editar Compra'
            : 'Adicionar Compra',
        onCancelar: () => Navigator.pop(context),
        onSalvar: _salvarCompra,
        labelSalvar: widget.compraInicial != null ? 'Salvar' : 'Adicionar',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Card principal com campos do formulario
            _buildFormulario(),

            const SizedBox(height: 16),

            // Dropdown de categoria (aparece quando expandido)
            if (_categoriaExpandida) _buildDropdownCategoria(),

            const SizedBox(height: 16),

            // Campo de data
            _buildCampoData(),

            const SizedBox(height: 16),

            // Botao de escanear QR
            _buildBotaoEscanearQR(),

            const SizedBox(height: 24),

            // Botao principal
            _buildBotaoAdicionar(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulario() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Nome do produto
          _CampoTexto(
            label: 'Produto',
            controller: _nomeController,
            placeholder: 'Ex: Arroz, Leite...',
          ),

          const Divider(height: 1, color: AppColors.border),

          // Preco
          _CampoTexto(
            label: 'Preço (R\$)',
            controller: _precoController,
            placeholder: '0,00',
            teclado: TextInputType.number,
            formatadores: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))
            ],
          ),

          const Divider(height: 1, color: AppColors.border),

          // Loja - agora visivel no formulario
          _CampoTexto(
            label: 'Loja',
            controller: _lojaController,
            placeholder: 'Ex: Supermercado, Farmácia...',
          ),

          const Divider(height: 1, color: AppColors.border),

          // Quantidade com botoes de incremento/decremento
          _buildCampoQuantidade(),

          const Divider(height: 1, color: AppColors.border),

          // Categoria com dropdown
          _buildCampoCategoria(),
        ],
      ),
    );
  }

  // Campo de quantidade com botoes funcionais de + e -
  Widget _buildCampoQuantidade() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Quantidade',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
          ),
          const Spacer(),
          // Botao decrementar
          GestureDetector(
            onTap: () {
              if (_quantidade > 1) setState(() => _quantidade--);
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _quantidade > 1
                    ? AppColors.primaryDark
                    : AppColors.searchBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.remove,
                size: 18,
                color: _quantidade > 1 ? Colors.white : AppColors.textTertiary,
              ),
            ),
          ),

          // Numero atual
          SizedBox(
            width: 44,
            child: Text(
              _quantidade.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Botao incrementar
          GestureDetector(
            onTap: () => setState(() => _quantidade++),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampoCategoria() {
    return InkWell(
      onTap: () =>
          setState(() => _categoriaExpandida = !_categoriaExpandida),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Text(
              'Categoria',
              style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
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
    );
  }

  Widget _buildDropdownCategoria() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: Categoria.values.map((cat) {
          final selecionada = cat == _categoriaSelecionada;
          return ListTile(
            title: Text(
              cat.nome,
              style: TextStyle(
                fontSize: 15,
                fontWeight:
                    selecionada ? FontWeight.w600 : FontWeight.w400,
                color:
                    selecionada ? AppColors.accent : AppColors.textPrimary,
              ),
            ),
            trailing: selecionada
                ? const Icon(Icons.check, color: AppColors.accent)
                : null,
            onTap: () => setState(() {
              _categoriaSelecionada = cat;
              _categoriaExpandida = false;
            }),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCampoData() {
    return GestureDetector(
      onTap: _selecionarData,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            const Text(
              'Data da compra',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              _formatarData(_dataSelecionada),
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.accent,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotaoEscanearQR() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: _escanearQRCode,
          icon: const Icon(Icons.qr_code_scanner, size: 20),
          label: const Text(
            'Escanear QR Code da Nota Fiscal',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.accent),
            foregroundColor: AppColors.accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBotaoAdicionar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _salvarCompra,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            widget.compraInicial != null ? 'Salvar Alterações' : 'Adicionar',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

// Campo de texto generico reutilizavel
class _CampoTexto extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final TextInputType teclado;
  final List<TextInputFormatter>? formatadores;

  const _CampoTexto({
    required this.label,
    required this.controller,
    required this.placeholder,
    this.teclado = TextInputType.text,
    this.formatadores,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 15, color: AppColors.textPrimary),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: teclado,
              textAlign: TextAlign.right,
              inputFormatters: formatadores,
              style: const TextStyle(
                  fontSize: 15, color: AppColors.textSecondary),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: const TextStyle(
                    color: AppColors.textTertiary, fontSize: 15),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
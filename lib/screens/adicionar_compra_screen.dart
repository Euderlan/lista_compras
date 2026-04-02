import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/compra.dart';
import '../models/produto_acabando.dart';
import '../theme/app_theme.dart';
import 'qr_scanner_screen.dart';

// Tela modal para adicionar uma nova compra com campos de nome,
// preco, quantidade, categoria e data
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
  // Controllers para capturar o texto digitado em cada campo
  final _nomeController = TextEditingController();
  final _precoController = TextEditingController();
  final _lojaController = TextEditingController();

  // Quantidade selecionada (padrao: 1)
  int _quantidade = 1;

  // Categoria selecionada (padrao: Mercado)
  Categoria _categoriaSelecionada = Categoria.mercado;

  // Data selecionada (padrao: hoje)
  DateTime _dataSelecionada = DateTime.now();

  // Controla se o dropdown de categoria esta expandido
  bool _categoriaExpandida = false;

  @override
  void initState() {
    super.initState();

    if (widget.compraInicial != null) {
      final compra = widget.compraInicial!;
      _nomeController.text = compra.nome;
      _precoController.text = compra.preco
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      _lojaController.text = compra.loja;
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

  // Formata a data no padrao dd/mm/yyyy
  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  // Abre o date picker nativo
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

  // Valida os campos e cria o objeto Compra para retornar
  void _salvarCompra() {
    final nome = _nomeController.text.trim();
    final precoTexto = _precoController.text.trim().replaceAll(',', '.');
    final loja = _lojaController.text.trim();

    // Validacao basica: nome e preco sao obrigatorios
    if (nome.isEmpty) {
      _mostrarErro('Informe o nome do produto');
      return;
    }

    final preco = double.tryParse(precoTexto);
    if (preco == null || preco <= 0) {
      _mostrarErro('Informe um preco valido');
      return;
    }

    // Cria o objeto com os dados preenchidos
    final novaCompra = Compra(
      id:
          widget.compraInicial?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome,
      preco: preco,
      quantidade: _quantidade,
      categoria: _categoriaSelecionada,
      loja: loja.isEmpty ? 'Sem loja' : loja,
      data: _dataSelecionada,
      marcado: widget.compraInicial?.marcado ?? false,
    );

    // Retorna a compra para a tela anterior
    Navigator.pop(context, novaCompra);
  }

  // Exibe um snackbar de erro com a mensagem informada
  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Abre a tela de scanner de QR code
  Future<void> _escanearQRCode() async {
    final scannedData = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );

    if (scannedData != null) {
      // Por enquanto, apenas mostra o dado escaneado
      // Futuramente, parsear os dados da nota fiscal
      _mostrarErro('QR Code escaneado: $scannedData');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // AppBar com botoes de cancelar e salvar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.compraInicial != null ? 'Editar Compra' : 'Adicionar Compra',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(fontSize: 15, color: AppColors.accent),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _salvarCompra,
            child: const Text(
              'Salvar',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Card com os campos do formulario
            _buildFormulario(),

            const SizedBox(height: 16),

            // Dropdown de categoria
            if (_categoriaExpandida) _buildDropdownCategoria(),

            const SizedBox(height: 16),

            // Campo de data com icone de calendario
            _buildCampoData(),

            const SizedBox(height: 16),

            // Botao para escanear QR code
            _buildBotaoEscanearQR(),

            const SizedBox(height: 32),

            // Botao principal de adicionar
            _buildBotaoAdicionar(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Card principal com os campos nome, preco e quantidade
  Widget _buildFormulario() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Campo nome do produto
          _CampoFormulario(
            label: 'Nome do Produto',
            controller: _nomeController,
            placeholder: 'Ex: Arroz, Leite...',
            ultimoCampo: false,
          ),

          const Divider(height: 1, color: AppColors.border),

          // Campo preco
          _CampoFormulario(
            label: 'Preco',
            controller: _precoController,
            placeholder: '0,00',
            teclado: TextInputType.number,
            ultimoCampo: false,
            exibirSeta: true,
          ),

          const Divider(height: 1, color: AppColors.border),

          // Campo quantidade com controles de incremento
          _CampoQuantidade(
            quantidade: _quantidade,
            onDecrementar: () {
              if (_quantidade > 1) setState(() => _quantidade--);
            },
            onIncrementar: () => setState(() => _quantidade++),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Campo categoria com dropdown
          _CampoCategoria(
            categoriaSelecionada: _categoriaSelecionada,
            expandida: _categoriaExpandida,
            onTap: () =>
                setState(() => _categoriaExpandida = !_categoriaExpandida),
          ),
        ],
      ),
    );
  }

  // Dropdown com todas as opcoes de categoria
  Widget _buildDropdownCategoria() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.5)),
      ),
      child: Column(
        children: Categoria.values.map((cat) {
          final selecionada = cat == _categoriaSelecionada;
          return ListTile(
            title: Text(
              cat.nome,
              style: TextStyle(
                fontSize: 15,
                fontWeight: selecionada ? FontWeight.w600 : FontWeight.w400,
                color: selecionada ? AppColors.accent : AppColors.textPrimary,
              ),
            ),
            trailing: selecionada
                ? const Icon(Icons.check, color: AppColors.accent)
                : null,
            onTap: () {
              setState(() {
                _categoriaSelecionada = cat;
                _categoriaExpandida = false;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  // Campo de selecao de data com icone de calendario
  Widget _buildCampoData() {
    return GestureDetector(
      onTap: _selecionarData,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            Text(
              _formatarData(_dataSelecionada),
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Botao verde de adicionar ao final da tela
  Widget _buildBotaoAdicionar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _salvarCompra,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            widget.compraInicial != null ? 'Salvar' : 'Adicionar',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // Botao para escanear QR code da nota fiscal
  Widget _buildBotaoEscanearQR() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: _escanearQRCode,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.accent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Escanear QR Code da Nota Fiscal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ),
      ),
    );
  }
}

// Campo de texto generico do formulario
class _CampoFormulario extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final TextInputType teclado;
  final bool ultimoCampo;
  final bool exibirSeta;

  const _CampoFormulario({
    required this.label,
    required this.controller,
    required this.placeholder,
    this.teclado = TextInputType.text,
    required this.ultimoCampo,
    this.exibirSeta = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Label do campo
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // Campo de input expandido
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: teclado,
              textAlign: TextAlign.right,
              inputFormatters: teclado == TextInputType.number
                  ? [FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))]
                  : null,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 15,
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          // Seta indicando campo editavel
          if (exibirSeta)
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textTertiary,
            ),
        ],
      ),
    );
  }
}

// Campo especial de quantidade com botoes de menos e mais
class _CampoQuantidade extends StatelessWidget {
  final int quantidade;
  final VoidCallback onDecrementar;
  final VoidCallback onIncrementar;

  const _CampoQuantidade({
    required this.quantidade,
    required this.onDecrementar,
    required this.onIncrementar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Text(
            'Quantidade',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
          ),
          const Spacer(),
          // Contador com botoes de incremento/decremento
          Text(
            quantidade.toString(),
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Campo de selecao de categoria com dropdown colapsavel
class _CampoCategoria extends StatelessWidget {
  final Categoria categoriaSelecionada;
  final bool expandida;
  final VoidCallback onTap;

  const _CampoCategoria({
    required this.categoriaSelecionada,
    required this.expandida,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Text(
              'Categoria',
              style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
            ),
            const Spacer(),
            // Nome da categoria selecionada em verde
            Text(
              categoriaSelecionada.nome,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.accent,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            // Seta que rotaciona ao expandir
            AnimatedRotation(
              turns: expandida ? 0.5 : 0,
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
}

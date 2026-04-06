import 'package:flutter/material.dart';
import '../models/compra.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';

// Servico que busca e parseia dados de nota fiscal via URL do QR Code
class NotaFiscalService {
  // Parseia produtos a partir da URL da SEFAZ
  // Por ora extrai informacoes basicas da URL e cria compras genericas
  // Para integracao completa seria necessario fazer scraping da pagina da SEFAZ
  static List<Compra> parsearUrlNota(String url) {
    // Extrai parametros da URL da nota fiscal
    // Formato: ...consultarNFCe.jsp?p=CHAVE|...|...
    // A chave contem: cUF|AAMM|CNPJ|mod|serie|nNF|tpEmis|cNF|cDV
    try {
     

      // Retorna lista vazia — a pagina da SEFAZ precisa ser acessada
      // para obter os produtos reais
      return [];
    } catch (_) {
      return [];
    }
  }
}

// Tela de revisao de produtos da nota fiscal
class RevisarNotaScreen extends StatefulWidget {
  final List<Compra> compras;

  const RevisarNotaScreen({super.key, required this.compras});

  @override
  State<RevisarNotaScreen> createState() => _RevisarNotaScreenState();
}

class _RevisarNotaScreenState extends State<RevisarNotaScreen> {
  late List<bool> _selecionados;

  @override
  void initState() {
    super.initState();
    _selecionados = List.filled(widget.compras.length, true);
  }

  double get _totalSelecionado {
    double total = 0;
    for (int i = 0; i < widget.compras.length; i++) {
      if (_selecionados[i]) total += widget.compras[i].total;
    }
    return total;
  }

  String _formatarValor(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    return 'R\$ ${partes[0]},${partes[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(titulo: 'Produtos da Nota Fiscal'),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.primaryDark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selecionados.where((s) => s).length} produto(s) selecionado(s)',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  _formatarValor(_totalSelecionado),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.compras.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textTertiary),
                          SizedBox(height: 12),
                          Text(
                            'Nenhum produto encontrado na nota',
                            style: TextStyle(fontSize: 15, color: AppColors.textTertiary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.compras.length,
                    itemBuilder: (context, index) {
                      final compra = widget.compras[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selecionados[index] ? AppColors.accent : AppColors.border,
                            width: _selecionados[index] ? 1.5 : 1,
                          ),
                        ),
                        child: CheckboxListTile(
                          value: _selecionados[index],
                          onChanged: (val) => setState(() => _selecionados[index] = val ?? true),
                          activeColor: AppColors.accent,
                          title: Text(compra.nome, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            '${compra.quantidade}x ${_formatarValor(compra.preco)} = ${_formatarValor(compra.total)}',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          secondary: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.searchBackground,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              compra.categoria.nome,
                              style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final selecionadas = <Compra>[];
                  for (int i = 0; i < widget.compras.length; i++) {
                    if (_selecionados[i]) selecionadas.add(widget.compras[i]);
                  }
                  Navigator.pop(context, selecionadas);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Adicionar Selecionados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
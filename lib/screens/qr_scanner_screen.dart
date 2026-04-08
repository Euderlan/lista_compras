import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/compra.dart';
import '../theme/app_theme.dart';
import '../screens/webview_nota_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  bool _processando = false;
  String _status = 'Aponte para o QR Code da nota fiscal';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // Processa o QR code escaneado — abre WebView para extrair produtos
  Future<void> _processarQR(String url) async {
    if (_processando) return;
    setState(() {
      _processando = true;
      _status = 'Abrindo nota fiscal...';
    });
    await controller.stop();

    if (!mounted) return;

    // Abre o WebView que carrega a pagina da SEFAZ e extrai os produtos
    final resultado = await Navigator.push<List<Compra>>(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewNotaScreen(url: url),
      ),
    );

    if (!mounted) return;
    // Retorna os produtos confirmados para o HomeScreen
    Navigator.pop(context, resultado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Escanear Nota Fiscal',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: AppColors.accent),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: controller,
            onDetect: (BarcodeCapture capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && !_processando) {
                final code = barcodes.first.rawValue;
                // Detecta QR de nota fiscal por URL ou por chave de 44 digitos
                final isNota = code != null && (
                  code.contains('nfce') ||
                  code.contains('nfe') ||
                  code.contains('sefaz') ||
                  code.contains('fazenda') ||
                  code.contains('consultarNFCe') ||
                  code.contains('consulta') ||
                  RegExp(r'[0-9]{44}').hasMatch(code)
                );
                if (isNota) {
                  _processarQR(code);
                }
              }
            },
          ),

          // Overlay de escurecimento nas bordas
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),

          // Area de scan transparente no centro
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.accent, width: 2.5),
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
              ),
            ),
          ),

          // Limpa o fundo da area de scan
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.width * 0.75,
                child: MobileScanner(
                  controller: controller,
                  onDetect: (_) {},
                ),
              ),
            ),
          ),

          // Status e loading
          Positioned(
            bottom: 80,
            left: 24,
            right: 24,
            child: Column(
              children: [
                if (_processando)
                  const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _processando ? 'Buscando produtos da nota...' : _status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
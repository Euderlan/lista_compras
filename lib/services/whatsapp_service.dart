import 'package:url_launcher/url_launcher.dart';
import '../models/produto_acabando.dart';

class WhatsAppService {
  static Future<void> compartilharLista(
    List<ProdutoAcabando> produtos,
  ) async {
    if (produtos.isEmpty) return;

    final buffer = StringBuffer();
    buffer.writeln('🛒 *Lista de Compras Futuras*');
    buffer.writeln();

    for (final produto in produtos) {
      if (produto.precoUltimo != null) {
        buffer.writeln('• ${produto.nome} — ${_formatarPreco(produto.precoUltimo!)}');
      } else {
        buffer.writeln('• ${produto.nome}');
      }
    }

    final totalEstimado = produtos
        .where((p) => p.precoUltimo != null)
        .fold(0.0, (soma, p) => soma + p.precoUltimo!);

    if (totalEstimado > 0) {
      buffer.writeln();
      buffer.writeln('💰 *Total estimado: ${_formatarPreco(totalEstimado)}*');
    }

    buffer.writeln();
    buffer.writeln('_Enviado pelo app Lista de Compras_');

    final texto = Uri.encodeComponent(buffer.toString());

    // Tenta abrir o app do WhatsApp direto (Android/iOS)
    final appUrl = Uri.parse('whatsapp://send?text=$texto');

    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl, mode: LaunchMode.externalApplication);
      return;
    }

    // Fallback: abre no navegador
    final webUrl = Uri.parse('https://api.whatsapp.com/send?text=$texto');
    if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  static String _formatarPreco(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    return 'R\$ ${partes[0]},${partes[1]}';
  }
}
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/compra.dart';
import '../theme/app_theme.dart';
import 'revisar_nota_screen.dart';

class WebViewNotaScreen extends StatefulWidget {
  final String url;

  const WebViewNotaScreen({super.key, required this.url});

  @override
  State<WebViewNotaScreen> createState() => _WebViewNotaScreenState();
}

class _WebViewNotaScreenState extends State<WebViewNotaScreen> {
  late WebViewController _controller;
  bool _carregando = true;
  bool _extraindo = false;
  String _status = 'Carregando nota fiscal...';

  // JavaScript montado em partes para evitar conflito de escape com Dart
  static String get _jsExtrator {
    final sb = StringBuffer();
    sb.writeln('(function() {');
    sb.writeln('  try {');
    sb.writeln('    var produtos = [];');
    sb.writeln('    var loja = "";');
    sb.writeln('    var lojaEl = document.querySelector("#nomeEmitente, .razaoSocial");');
    sb.writeln('    if (lojaEl) loja = lojaEl.innerText.trim().substring(0, 80);');
    sb.writeln('    var linhas = document.querySelectorAll("table#tabResult tr, .item, tr");');
    sb.writeln('    linhas.forEach(function(linha) {');
    sb.writeln('      var nomeEl = linha.querySelector(".nome_item, .txtTit, td:first-child");');
    sb.writeln('      var nome = nomeEl ? nomeEl.innerText.trim() : "";');
    sb.writeln('      var qtdEl = linha.querySelector(".Qcom");');
    sb.writeln('      var qtd = qtdEl ? parseFloat(qtdEl.innerText.replace(",",".")) || 1 : 1;');
    sb.writeln('      var valorEl = linha.querySelector(".VunCom, td:nth-child(3)");');
    sb.writeln('      var vt = "0";');
    sb.writeln('      if (valorEl) {');
    sb.writeln('        vt = valorEl.innerText.trim();');
    sb.writeln('        vt = vt.split("R").join("").split(" ").join("");');
    sb.writeln('        vt = vt.split(".").join("").split(",").join(".");');
    sb.writeln('      }');
    sb.writeln('      var valor = parseFloat(vt) || 0;');
    sb.writeln('      if (nome && nome.length > 2 && valor > 0) {');
    sb.writeln('        produtos.push({ nome: nome.substring(0,100), quantidade: Math.round(qtd), preco: valor });');
    sb.writeln('      }');
    sb.writeln('    });');
    sb.writeln('    if (produtos.length === 0) {');
    sb.writeln('      document.querySelectorAll("span.txtTit, span.Nome").forEach(function(sp) {');
    sb.writeln('        var c = sp.closest("tr, .item, li");');
    sb.writeln('        if (!c) return;');
    sb.writeln('        var nome = sp.innerText.trim();');
    sb.writeln('        var preco = 0;');
    sb.writeln('        c.querySelectorAll("span").forEach(function(v) {');
    sb.writeln('          var raw = v.innerText.split(",").join(".");');
    sb.writeln('          var n = parseFloat(raw);');
    sb.writeln('          if (n > 0 && preco === 0) preco = n;');
    sb.writeln('        });');
    sb.writeln('        if (nome && preco > 0) produtos.push({ nome: nome, quantidade: 1, preco: preco });');
    sb.writeln('      });');
    sb.writeln('    }');
    sb.writeln('    return JSON.stringify({ produtos: produtos, loja: loja });');
    sb.writeln('  } catch(e) {');
    sb.writeln('    return JSON.stringify({ produtos: [], loja: "", erro: e.toString() });');
    sb.writeln('  }');
    sb.writeln('})();');
    return sb.toString();
  }

  @override
  void initState() {
    super.initState();
    _inicializarWebView();
  }

  void _inicializarWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _carregando = true;
            _status = 'Carregando nota fiscal...';
          }),
          onPageFinished: (_) {
            setState(() => _carregando = false);
            Future.delayed(const Duration(seconds: 2), _extrairProdutos);
          },
          onWebResourceError: (_) => setState(() {
            _carregando = false;
            _status = 'Erro ao carregar a pagina.';
          }),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _extrairProdutos() async {
    if (_extraindo) return;
    setState(() {
      _extraindo = true;
      _status = 'Extraindo produtos...';
    });

    try {
      final resultado =
          await _controller.runJavaScriptReturningResult(_jsExtrator);

      final json = resultado.toString();
      final jsonLimpo = json.startsWith('"') && json.endsWith('"')
          ? json.substring(1, json.length - 1).replaceAll(r'\"', '"')
          : json;

      final compras = _parsearJson(jsonLimpo);

      if (!mounted) return;

      if (compras.isEmpty) {
        setState(() {
          _extraindo = false;
          _status = 'Nenhum produto encontrado. Tente novamente.';
        });
        return;
      }

      final confirmados = await Navigator.push<List<Compra>>(
        context,
        MaterialPageRoute(
            builder: (_) => RevisarNotaScreen(compras: compras)),
      );

      if (!mounted) return;
      Navigator.pop(context, confirmados);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _extraindo = false;
        _status = 'Erro ao extrair. Tente novamente.';
      });
    }
  }

  List<Compra> _parsearJson(String json) {
    final compras = <Compra>[];
    try {
      final produtosMatch =
          RegExp(r'"produtos":\[(.*?)\]', dotAll: true).firstMatch(json);
      if (produtosMatch == null) return [];

      final lojaMatch = RegExp(r'"loja":"([^"]*)"').firstMatch(json);
      final loja = lojaMatch?.group(1) ?? 'Nota Fiscal';

      for (final itemMatch
          in RegExp(r'\{[^}]+\}').allMatches(produtosMatch.group(1) ?? '')) {
        final item = itemMatch.group(0) ?? '';
        final nome =
            RegExp(r'"nome":"([^"]*)"').firstMatch(item)?.group(1) ?? '';
        final qtd = int.tryParse(
                RegExp(r'"quantidade":(\d+)').firstMatch(item)?.group(1) ??
                    '1') ??
            1;
        final preco = double.tryParse(
                RegExp(r'"preco":([\d.]+)').firstMatch(item)?.group(1) ??
                    '0') ??
            0.0;

        if (nome.isNotEmpty && preco > 0) {
          compras.add(Compra(
            id: DateTime.now().millisecondsSinceEpoch.toString() +
                compras.length.toString(),
            nome: _capitalizar(nome),
            preco: preco,
            quantidade: qtd,
            categoria: _inferirCategoria(nome),
            loja: loja.isNotEmpty ? loja : 'Nota Fiscal',
            data: DateTime.now(),
            marcado: false,
          ));
        }
      }
    } catch (_) {}
    return compras;
  }

  String _capitalizar(String nome) {
    return nome
        .toLowerCase()
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  Categoria _inferirCategoria(String nome) {
    final n = nome.toLowerCase();
    if (RegExp(r'sabonete|shampoo|condicionador|pasta dent|escova|desodorante|absorvente|fralda|papel higi|detergente|sabao|amaciante|alcool|curativo')
        .hasMatch(n)) return Categoria.higiene;
    if (RegExp(r'fruta|legume|verdura|cenoura|tomate|alface|cebola|batata|banana|maca|laranja|limao|mamao|abacate|uva|morango|brocolis|couve|pepino')
        .hasMatch(n)) return Categoria.hortifruti;
    if (RegExp(r'arroz|feijao|macarrao|oleo|sal |acucar|cafe|leite|manteiga|margarina|queijo|iogurte|carne|frango|peixe|ovo |pao|biscoito|farinha|molho|refrigerante|suco|agua')
        .hasMatch(n)) return Categoria.mercado;
    return Categoria.outros;
  }

  @override
  Widget build(BuildContext context) {
    final falhou = !_carregando &&
        !_extraindo &&
        (_status.contains('Nenhum') || _status.contains('Erro'));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: const Text(
          'Nota Fiscal',
          style: TextStyle(
              color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_carregando && !_extraindo)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Tentar novamente',
              onPressed: _extrairProdutos,
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),

          if (_carregando || _extraindo)
            Container(
              color: Colors.black.withValues(alpha: 0.55),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                          color: AppColors.primaryDark),
                      const SizedBox(height: 16),
                      Text(
                        _status,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (falhou)
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: ElevatedButton.icon(
                onPressed: _extrairProdutos,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar extrair novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
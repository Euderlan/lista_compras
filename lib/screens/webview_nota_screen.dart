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
  bool _notaCarregada = false;
  String _status = 'Aguarde...';

  // Lista de dados de estoque extraídos da nota para rastreamento
  final List<Map<String, dynamic>> _produtosEstoqueExtraidos = [];

  // JavaScript para o portal RJ (fazenda.rj.gov.br) e SEFAZ-MA
  static String get _jsExtrator {
    final sb = StringBuffer();
    sb.writeln('(function() {');
    sb.writeln('  try {');
    sb.writeln('    var produtos = [];');
    sb.writeln('    var loja = "";');

    sb.writeln('    var lojaSelectors = [".txtTopo", "#u20", "#nomeEmitente", ".NomEmit", ".razaoSocial", "h2.text-center"];');
    sb.writeln('    for (var i = 0; i < lojaSelectors.length; i++) {');
    sb.writeln('      var el = document.querySelector(lojaSelectors[i]);');
    sb.writeln('      if (el && el.innerText.trim().length > 2) { loja = el.innerText.trim().substring(0,80); break; }');
    sb.writeln('    }');

    sb.writeln('    var linhasMA = document.querySelectorAll("table#tabResult tr");');
    sb.writeln('    if (linhasMA.length > 0) {');
    sb.writeln('      linhasMA.forEach(function(linha) {');
    sb.writeln('        var nomeEl = linha.querySelector("span.txtTit");');
    sb.writeln('        if (!nomeEl) return;');
    sb.writeln('        var nome = nomeEl.innerText.trim();');
    sb.writeln('        if (!nome || nome.length < 2) return;');
    sb.writeln('        var qtdEl = linha.querySelector("span.Rqtd");');
    sb.writeln('        var qtdTxt = qtdEl ? qtdEl.innerText.replace("Qtde.:","").trim() : "1";');
    sb.writeln('        var qtd = parseInt(qtdTxt) || 1;');
    sb.writeln('        var valorEl = linha.querySelector("span.RvlUnit");');
    sb.writeln('        var valorTxt = valorEl ? valorEl.innerText.replace("Vl. Unit.:","").trim() : "0";');
    sb.writeln('        valorTxt = valorTxt.split(".").join("").split(",").join(".");');
    sb.writeln('        var valor = parseFloat(valorTxt) || 0;');
    sb.writeln('        if (valor === 0) {');
    sb.writeln('          var totalEl = linha.querySelector("span.valor");');
    sb.writeln('          var totalTxt = totalEl ? totalEl.innerText.split(".").join("").split(",").join(".") : "0";');
    sb.writeln('          valor = parseFloat(totalTxt) / qtd || 0;');
    sb.writeln('        }');
    sb.writeln('        if (valor > 0) produtos.push({ nome: nome.substring(0,100), quantidade: qtd, preco: parseFloat(valor.toFixed(2)) });');
    sb.writeln('      });');
    sb.writeln('    }');

    sb.writeln('    if (produtos.length === 0) {');
    sb.writeln('      var linhasRJ = document.querySelectorAll("table.toItens tbody tr, .item-list tr, #tableItens tr");');
    sb.writeln('      linhasRJ.forEach(function(linha) {');
    sb.writeln('        var cells = linha.querySelectorAll("td");');
    sb.writeln('        if (cells.length < 2) return;');
    sb.writeln('        var nome = cells[0].innerText.trim();');
    sb.writeln('        if (!nome || nome.length < 2) return;');
    sb.writeln('        var qtd = 1;');
    sb.writeln('        var valor = 0;');
    sb.writeln('        for (var c = 1; c < cells.length; c++) {');
    sb.writeln('          var t = cells[c].innerText.trim().split(".").join("").split(",").join(".");');
    sb.writeln('          var n = parseFloat(t);');
    sb.writeln('          if (n > 0 && n < 100000) { valor = n; }');
    sb.writeln('        }');
    sb.writeln('        if (valor > 0) produtos.push({ nome: nome.substring(0,100), quantidade: qtd, preco: parseFloat(valor.toFixed(2)) });');
    sb.writeln('      });');
    sb.writeln('    }');

    sb.writeln('    if (produtos.length === 0) {');
    sb.writeln('      document.querySelectorAll("span.txtTit").forEach(function(el) {');
    sb.writeln('        var nome = el.innerText.trim();');
    sb.writeln('        if (!nome || nome.length < 2) return;');
    sb.writeln('        var container = el.closest("tr, li, .item");');
    sb.writeln('        if (!container) return;');
    sb.writeln('        var valor = 0;');
    sb.writeln('        container.querySelectorAll("span.valor, span.RvlUnit, td").forEach(function(v) {');
    sb.writeln('          var t = v.innerText.trim().split(".").join("").split(",").join(".");');
    sb.writeln('          var n = parseFloat(t);');
    sb.writeln('          if (n > 0 && valor === 0) valor = n;');
    sb.writeln('        });');
    sb.writeln('        if (valor > 0) produtos.push({ nome: nome.substring(0,100), quantidade: 1, preco: valor });');
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

  String _extrairChave(String url) {
    try {
      final uri = Uri.parse(url);
      final p = uri.queryParameters['p'] ?? '';
      if (p.isNotEmpty) {
        final partes = p.split('|');
        if (partes.isNotEmpty && partes[0].length == 44) {
          return partes[0];
        }
        final soNumeros = p.replaceAll(RegExp(r'[^0-9]'), '');
        if (soNumeros.length >= 44) {
          return soNumeros.substring(0, 44);
        }
      }
      final match = RegExp(r'[0-9]{44}').firstMatch(url);
      return match?.group(0) ?? '';
    } catch (_) {
      return '';
    }
  }

  String _montarUrlRJ(String urlOriginal) {
    final chave = _extrairChave(urlOriginal);
    if (chave.isNotEmpty) {
      return 'https://www.fazenda.rj.gov.br/nfce/consulta?p=$chave|2|1|1|';
    }
    return 'https://www.fazenda.rj.gov.br/nfce/consulta';
  }

  void _inicializarWebView() {
    final urlRJ = _montarUrlRJ(widget.url);

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
          onPageFinished: (url) {
            setState(() => _carregando = false);
            _preencherChaveRJ();
            _verificarSeNotaCarregou();
          },
          onWebResourceError: (_) => setState(() {
            _carregando = false;
          }),
          onNavigationRequest: (_) => NavigationDecision.navigate,
        ),
      )
      ..loadRequest(Uri.parse(urlRJ));
  }

  Future<void> _preencherChaveRJ() async {
    final chave = _extrairChave(widget.url);
    if (chave.isEmpty) {
      return;
    }

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      await _controller.runJavaScript('''
        (function() {
          var inputs = document.querySelectorAll("input[type=text], input[type=search], input:not([type])");
          for (var i = 0; i < inputs.length; i++) {
            var placeholder = (inputs[i].placeholder || "").toLowerCase();
            var name = (inputs[i].name || "").toLowerCase();
            var id = (inputs[i].id || "").toLowerCase();
            if (placeholder.includes("chave") || name.includes("chave") || id.includes("chave") ||
                placeholder.includes("acesso") || name.includes("acesso") || id.includes("acesso") ||
                placeholder.includes("nfe") || name.includes("nfe")) {
              inputs[i].value = "$chave";
              inputs[i].dispatchEvent(new Event("input", { bubbles: true }));
              inputs[i].dispatchEvent(new Event("change", { bubbles: true }));
              break;
            }
          }
          var allInputs = document.querySelectorAll("input[type=text]");
          if (allInputs.length > 0 && allInputs[0].value === "") {
            allInputs[0].value = "$chave";
            allInputs[0].dispatchEvent(new Event("input", { bubbles: true }));
            allInputs[0].dispatchEvent(new Event("change", { bubbles: true }));
          }
        })();
      ''');
    } catch (_) {}
  }

  Future<void> _verificarSeNotaCarregou() async {
    try {
      final resultado = await _controller.runJavaScriptReturningResult(
        'document.querySelector("table#tabResult") !== null ? "sim" : "nao"',
      );
      final temTabela = resultado.toString().contains('sim');
      if (mounted) {
        setState(() {
          _notaCarregada = temTabela;
          _status = temTabela
              ? 'Nota carregada! Toque em "Extrair Produtos"'
              : 'Resolva o CAPTCHA e consulte a nota';
        });
      }
    } catch (_) {}
  }

  Future<void> _extrairProdutos() async {
    if (_extraindo) {
      return;
    }
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

      _produtosEstoqueExtraidos.clear();

      final compras = _parsearJson(jsonLimpo);

      if (!mounted) {
        return;
      }

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
          builder: (_) => RevisarNotaScreen(compras: compras),
        ),
      );

      if (!mounted) {
        return;
      }

      if (confirmados == null) {
        setState(() {
          _extraindo = false;
          _status = 'Extração cancelada.';
        });
        return;
      }

      final nomesConfirmados =
          confirmados.map((c) => c.nome.toLowerCase()).toSet();
      final estoquesConfirmados = _produtosEstoqueExtraidos
          .where((e) => nomesConfirmados
              .contains((e['nome'] as String).toLowerCase()))
          .toList();

      Navigator.pop(context, {
        'compras': confirmados,
        'estoques': estoquesConfirmados,
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
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
      if (produtosMatch == null) {
        return [];
      }

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
          final nomeCapitalizado = _capitalizar(nome);
          final categoria = _inferirCategoria(nome);

          compras.add(Compra(
            id: DateTime.now().millisecondsSinceEpoch.toString() +
                compras.length.toString(),
            nome: nomeCapitalizado,
            preco: preco,
            quantidade: qtd,
            categoria: categoria,
            loja: loja.isNotEmpty ? loja : 'Nota Fiscal',
            data: DateTime.now(),
            marcado: false,
          ));

          final unidade = _inferirUnidade(nome);
          final pesoUnitario = _inferirPesoUnitario(nome, unidade);

          _produtosEstoqueExtraidos.add({
            'nome': nomeCapitalizado,
            'categoria': categoria,
            'quantidade': qtd.toDouble(),
            'unidade': unidade,
            'peso_unitario': pesoUnitario,
          });
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
    if (RegExp(
      r'sabonete|shampoo|condicionador|pasta dent|escova|desodorante|absorvente|fralda|papel higi|detergente|sabao|amaciante|alcool|curativo',
    ).hasMatch(n)) {
      return Categoria.higiene;
    }
    if (RegExp(
      r'fruta|legume|verdura|cenoura|tomate|alface|cebola|batata|banana|maca|laranja|limao|mamao|abacate|uva|morango|brocolis|couve|pepino',
    ).hasMatch(n)) {
      return Categoria.hortifruti;
    }
    if (RegExp(
      r'arroz|feijao|macarrao|oleo|sal |acucar|cafe|leite|manteiga|margarina|queijo|iogurte|carne|frango|peixe|ovo |pao|biscoito|farinha|molho|refrigerante|suco|agua',
    ).hasMatch(n)) {
      return Categoria.mercado;
    }
    return Categoria.outros;
  }

  String _inferirUnidade(String nome) {
    final n = nome.toLowerCase();
    if (RegExp(r'\bkg\b|quilo').hasMatch(n)) {
      return 'kg';
    }
    if (RegExp(r'\bml\b|mililitro').hasMatch(n)) {
      return 'ml';
    }
    if (RegExp(r'\bl\b|litro|\blt\b').hasMatch(n)) {
      return 'L';
    }
    if (RegExp(r'\bg\b|grama').hasMatch(n)) {
      return 'g';
    }
    return 'un';
  }

  double _inferirPesoUnitario(String nome, String unidade) {
    final n = nome.toLowerCase();

    final match = RegExp(
      r'(\d+[\.,]?\d*)\s*(kg|g|l|ml|lt)',
      caseSensitive: false,
    ).firstMatch(n);

    if (match != null) {
      final valor =
          double.tryParse(match.group(1)!.replaceAll(',', '.')) ?? 1.0;
      final unidadeEncontrada = match.group(2)!.toLowerCase();
      if (unidadeEncontrada == 'kg') {
        return valor * 1000;
      }
      if (unidadeEncontrada == 'l' || unidadeEncontrada == 'lt') {
        return valor * 1000;
      }
      return valor;
    }

    switch (unidade) {
      case 'kg': { return 1000; }
      case 'L': { return 1000; }
      case 'ml': { return 250; }
      case 'g': { return 500; }
      default: { return 100; }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: const Text(
          'Nota Fiscal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Verificar novamente',
            onPressed: _verificarSeNotaCarregou,
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: _notaCarregada ? AppColors.accent : Colors.orange.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(
                  _notaCarregada
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _status,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                if (_carregando)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),

                if (_extraindo)
                  Container(
                    color: Colors.black.withValues(alpha: 0.6),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(32),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.primaryDark,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Extraindo produtos da nota...',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _extraindo ? null : _extrairProdutos,
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: Text(
                    _extraindo ? 'Extraindo...' : 'Extrair Produtos da Nota',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primaryDark.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
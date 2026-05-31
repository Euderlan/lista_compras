import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/compra.dart';
import '../models/produto_acabando.dart';

class ProdutosAcabandoService {
  final _supabase = Supabase.instance.client;

  String get _usuarioId => _supabase.auth.currentUser!.id;

  Categoria _stringParaCategoria(String s) {
    switch (s) {
      case 'mercado': return Categoria.mercado;
      case 'higiene': return Categoria.higiene;
      case 'hortifruti': return Categoria.hortifruti;
      default: return Categoria.outros;
    }
  }

  String _categoriaParaString(Categoria cat) {
    switch (cat) {
      case Categoria.mercado: return 'mercado';
      case Categoria.higiene: return 'higiene';
      case Categoria.hortifruti: return 'hortifruti';
      case Categoria.outros: return 'outros';
    }
  }

  ProdutoAcabando _mapParaProduto(Map<String, dynamic> map) {
    return ProdutoAcabando(
      id: map['id'] as String,
      nome: map['nome'] as String,
      categoria: _stringParaCategoria(map['categoria'] as String),
      dataMarcado: DateTime.parse(map['data_marcado'] as String),
      precoUltimo: map['preco_ultimo'] != null
          ? (map['preco_ultimo'] as num).toDouble()
          : null,
    );
  }

  Future<List<ProdutoAcabando>> buscarProdutos() async {
    final response = await _supabase
        .from('produtos_acabando')
        .select()
        .eq('usuario_id', _usuarioId)
        .order('criado_em', ascending: true);

    return (response as List).map((m) => _mapParaProduto(m)).toList();
  }

  Future<ProdutoAcabando> adicionarProduto(ProdutoAcabando produto) async {
    final data = {
      'usuario_id': _usuarioId,
      'nome': produto.nome,
      'categoria': _categoriaParaString(produto.categoria),
      'data_marcado': produto.dataMarcado.toIso8601String(),
      'preco_ultimo': produto.precoUltimo,
    };

    final response = await _supabase
        .from('produtos_acabando')
        .insert(data)
        .select()
        .single();

    return _mapParaProduto(response);
  }

  Future<ProdutoAcabando> atualizarProduto(ProdutoAcabando produto) async {
    final data = {
      'nome': produto.nome,
      'categoria': _categoriaParaString(produto.categoria),
      'preco_ultimo': produto.precoUltimo,
    };

    final response = await _supabase
        .from('produtos_acabando')
        .update(data)
        .eq('id', produto.id)
        .eq('usuario_id', _usuarioId)
        .select()
        .single();

    return _mapParaProduto(response);
  }

  Future<void> removerProduto(String id) async {
    await _supabase
        .from('produtos_acabando')
        .delete()
        .eq('id', id)
        .eq('usuario_id', _usuarioId);
  }

  // Remove produtos semelhantes ao nome dado (para quando a nota fiscal é escaneada)
  // Usa comparação normalizada para lidar com nomes diferentes
  Future<List<String>> removerSemelhantes(List<String> nomesComprados) async {
    final produtos = await buscarProdutos();
    final removidos = <String>[];

    for (final produto in produtos) {
      if (_ehSemelhante(produto.nome, nomesComprados)) {
        await removerProduto(produto.id);
        removidos.add(produto.nome);
      }
    }

    return removidos;
  }

  // Verifica se um nome de produto é semelhante a algum da lista comprada
  bool _ehSemelhante(String nomeProduto, List<String> nomesComprados) {
    final normalizado = _normalizar(nomeProduto);

    for (final nomeComprado in nomesComprados) {
      final normalizadoComprado = _normalizar(nomeComprado);

      // Correspondência exata normalizada
      if (normalizado == normalizadoComprado) {
        return true;
      }

      // Um contém o outro (ex: "Arroz 5kg" contém "Arroz")
      if (normalizado.contains(normalizadoComprado) ||
          normalizadoComprado.contains(normalizado)) {
        return true;
      }

      // Similaridade por palavras em comum (>= 60% das palavras batem)
      if (_similaridadePalavras(normalizado, normalizadoComprado) >= 0.6) {
        return true;
      }
    }

    return false;
  }

  // Normaliza string: minúsculas, sem acentos, sem caracteres especiais
  String _normalizar(String texto) {
    var resultado = texto.toLowerCase().trim();
    const acentos = {
      'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a', 'ä': 'a',
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
      'ó': 'o', 'ò': 'o', 'õ': 'o', 'ô': 'o', 'ö': 'o',
      'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
      'ç': 'c', 'ñ': 'n',
    };
    for (final entry in acentos.entries) {
      resultado = resultado.replaceAll(entry.key, entry.value);
    }
    // Remove números e unidades de medida para comparação mais ampla
    resultado = resultado
        .replaceAll(RegExp(r'\d+[\.,]?\d*\s*(kg|g|ml|l|lt|un|pct|cx)\b',
            caseSensitive: false), '')
        .replaceAll(RegExp(r'[^a-z\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return resultado;
  }

  // Calcula fração de palavras em comum entre dois textos normalizados
  double _similaridadePalavras(String a, String b) {
    final palavrasA = a.split(' ').where((p) => p.length > 2).toSet();
    final palavrasB = b.split(' ').where((p) => p.length > 2).toSet();

    if (palavrasA.isEmpty || palavrasB.isEmpty) {
      return 0;
    }

    final intersecao = palavrasA.intersection(palavrasB).length;
    final menor = palavrasA.length < palavrasB.length
        ? palavrasA.length
        : palavrasB.length;

    return intersecao / menor;
  }
}
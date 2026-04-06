import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/compra.dart';
import '../models/produto_acabando.dart';

class ProdutosAcabandoService {
  final _supabase = Supabase.instance.client;

  String get _usuarioId => _supabase.auth.currentUser!.id;

  Categoria _stringParaCategoria(String s) {
    switch (s) {
      case 'mercado':
        return Categoria.mercado;
      case 'higiene':
        return Categoria.higiene;
      case 'hortifruti':
        return Categoria.hortifruti;
      default:
        return Categoria.outros;
    }
  }

  String _categoriaParaString(Categoria cat) {
    switch (cat) {
      case Categoria.mercado:
        return 'mercado';
      case Categoria.higiene:
        return 'higiene';
      case Categoria.hortifruti:
        return 'hortifruti';
      case Categoria.outros:
        return 'outros';
    }
  }

  ProdutoAcabando _mapParaProduto(Map<String, dynamic> map) {
    return ProdutoAcabando(
      id: map['id'] as String,
      nome: map['nome'] as String,
      categoria: _stringParaCategoria(map['categoria'] as String),
      dataMarcado: DateTime.parse(map['data_marcado'] as String),
    );
  }

  // Busca todos os produtos acabando do usuario
  Future<List<ProdutoAcabando>> buscarProdutos() async {
    final response = await _supabase
        .from('produtos_acabando')
        .select()
        .eq('usuario_id', _usuarioId)
        .order('criado_em', ascending: true);

    return (response as List).map((m) => _mapParaProduto(m)).toList();
  }

  // Adiciona produto acabando
  Future<ProdutoAcabando> adicionarProduto(ProdutoAcabando produto) async {
    final data = {
      'usuario_id': _usuarioId,
      'nome': produto.nome,
      'categoria': _categoriaParaString(produto.categoria),
      'data_marcado': produto.dataMarcado.toIso8601String(),
    };

    final response = await _supabase
        .from('produtos_acabando')
        .insert(data)
        .select()
        .single();

    return _mapParaProduto(response);
  }

  // Remove produto acabando
  Future<void> removerProduto(String id) async {
    await _supabase
        .from('produtos_acabando')
        .delete()
        .eq('id', id)
        .eq('usuario_id', _usuarioId);
  }
}
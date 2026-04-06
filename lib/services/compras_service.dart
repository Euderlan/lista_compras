import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/compra.dart';

// Servico de acesso ao banco para compras
class ComprasService {
  final _supabase = Supabase.instance.client;

  String get _usuarioId => _supabase.auth.currentUser!.id;

  // Converte categoria enum para string do banco
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

  // Converte string do banco para enum
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

  // Converte Map do banco para objeto Compra
  Compra _mapParaCompra(Map<String, dynamic> map) {
    return Compra(
      id: map['id'] as String,
      nome: map['nome'] as String,
      preco: (map['preco'] as num).toDouble(),
      quantidade: map['quantidade'] as int,
      categoria: _stringParaCategoria(map['categoria'] as String),
      loja: map['loja'] as String,
      data: DateTime.parse(map['data'] as String),
      marcado: map['marcado'] as bool,
    );
  }

  // Busca todas as compras do mes atual
  Future<List<Compra>> buscarComprasMes(String mesAno) async {
    final response = await _supabase
        .from('compras')
        .select()
        .eq('usuario_id', _usuarioId)
        .eq('mes_ano', mesAno)
        .order('criado_em', ascending: true);

    return (response as List).map((m) => _mapParaCompra(m)).toList();
  }

  // Adiciona nova compra
  Future<Compra> adicionarCompra(Compra compra, String mesAno) async {
    final data = {
      'usuario_id': _usuarioId,
      'nome': compra.nome,
      'preco': compra.preco,
      'quantidade': compra.quantidade,
      'categoria': _categoriaParaString(compra.categoria),
      'loja': compra.loja,
      'data': compra.data.toIso8601String().substring(0, 10),
      'marcado': compra.marcado,
      'mes_ano': mesAno,
    };

    final response =
        await _supabase.from('compras').insert(data).select().single();

    return _mapParaCompra(response);
  }

  // Atualiza compra existente
  Future<Compra> atualizarCompra(Compra compra) async {
    final data = {
      'nome': compra.nome,
      'preco': compra.preco,
      'quantidade': compra.quantidade,
      'categoria': _categoriaParaString(compra.categoria),
      'loja': compra.loja,
      'data': compra.data.toIso8601String().substring(0, 10),
      'marcado': compra.marcado,
      'atualizado_em': DateTime.now().toIso8601String(),
    };

    final response = await _supabase
        .from('compras')
        .update(data)
        .eq('id', compra.id)
        .eq('usuario_id', _usuarioId)
        .select()
        .single();

    return _mapParaCompra(response);
  }

  // Remove uma compra
  Future<void> removerCompra(String id) async {
    await _supabase
        .from('compras')
        .delete()
        .eq('id', id)
        .eq('usuario_id', _usuarioId);
  }

  // Remove todas as compras de um mes (ao fechar mes)
  Future<void> removerComprasMes(String mesAno) async {
    await _supabase
        .from('compras')
        .delete()
        .eq('usuario_id', _usuarioId)
        .eq('mes_ano', mesAno);
  }
}
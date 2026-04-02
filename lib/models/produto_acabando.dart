import 'compra.dart';

// Representa um produto que esta acabando e precisa ser reabastecido
class ProdutoAcabando {
  final String id;
  final String nome;
  final Categoria categoria;
  final DateTime dataMarcado;

  const ProdutoAcabando({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.dataMarcado,
  });

  ProdutoAcabando copyWith({
    String? id,
    String? nome,
    Categoria? categoria,
    DateTime? dataMarcado,
  }) {
    return ProdutoAcabando(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      dataMarcado: dataMarcado ?? this.dataMarcado,
    );
  }
}
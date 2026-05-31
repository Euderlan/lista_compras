import 'compra.dart';

class ProdutoAcabando {
  final String id;
  final String nome;
  final Categoria categoria;
  final DateTime dataMarcado;
  final double? precoUltimo; // preço da última compra, se disponível

  const ProdutoAcabando({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.dataMarcado,
    this.precoUltimo,
  });

  ProdutoAcabando copyWith({
    String? id,
    String? nome,
    Categoria? categoria,
    DateTime? dataMarcado,
    double? precoUltimo,
  }) {
    return ProdutoAcabando(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      dataMarcado: dataMarcado ?? this.dataMarcado,
      precoUltimo: precoUltimo ?? this.precoUltimo,
    );
  }
}
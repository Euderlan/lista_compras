import 'compra.dart';

// Modelo que representa um produto com informações de estoque para rastrear quando vai acabar
class ProdutoEstoque {
  final String id;
  final String usuarioId;
  final String nome;
  final Categoria categoria;
  final double quantidade;
  final String unidade; // 'kg', 'g', 'L', 'ml', 'un'
  final double pesoUnitario; // peso/volume por unidade em gramas ou ml
  final DateTime dataCompra;
  final String mesAno;
  final bool acabou;
  final DateTime? proximaNotificacao;
  final int diasSnooze; // dias para próxima notificação se "ainda não"

  const ProdutoEstoque({
    required this.id,
    required this.usuarioId,
    required this.nome,
    required this.categoria,
    required this.quantidade,
    required this.unidade,
    required this.pesoUnitario,
    required this.dataCompra,
    required this.mesAno,
    this.acabou = false,
    this.proximaNotificacao,
    this.diasSnooze = 5,
  });

  // Calcula o score de prioridade — menor score = perguntar primeiro
  // Leva em conta quantidade e peso total
  double get scorePrioridade {
    final pesoTotal = quantidade * pesoUnitario;
    // Normaliza: produtos mais leves e em menor quantidade têm score menor
    // e portanto são perguntados primeiro
    return pesoTotal * quantidade;
  }

  ProdutoEstoque copyWith({
    String? id,
    String? usuarioId,
    String? nome,
    Categoria? categoria,
    double? quantidade,
    String? unidade,
    double? pesoUnitario,
    DateTime? dataCompra,
    String? mesAno,
    bool? acabou,
    DateTime? proximaNotificacao,
    int? diasSnooze,
  }) {
    return ProdutoEstoque(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      quantidade: quantidade ?? this.quantidade,
      unidade: unidade ?? this.unidade,
      pesoUnitario: pesoUnitario ?? this.pesoUnitario,
      dataCompra: dataCompra ?? this.dataCompra,
      mesAno: mesAno ?? this.mesAno,
      acabou: acabou ?? this.acabou,
      proximaNotificacao: proximaNotificacao ?? this.proximaNotificacao,
      diasSnooze: diasSnooze ?? this.diasSnooze,
    );
  }
}
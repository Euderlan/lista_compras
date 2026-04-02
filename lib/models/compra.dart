// Categorias disponiveis para classificar os produtos
enum Categoria {
  mercado,
  higiene,
  hortifruti,
  outros,
}

// Retorna o nome legivel da categoria
extension CategoriaExtension on Categoria {
  String get nome {
    switch (this) {
      case Categoria.mercado:
        return 'Mercado';
      case Categoria.higiene:
        return 'Higiene';
      case Categoria.hortifruti:
        return 'Hortifruti';
      case Categoria.outros:
        return 'Outros';
    }
  }
}

// Representa um item de compra individual
class Compra {
  final String id;
  final String nome;
  final double preco;
  final int quantidade;
  final Categoria categoria;
  final String loja;
  final DateTime data;
  final bool marcado;

  const Compra({
    required this.id,
    required this.nome,
    required this.preco,
    required this.quantidade,
    required this.categoria,
    required this.loja,
    required this.data,
    this.marcado = false,
  });

  // Valor total do item (preco x quantidade)
  double get total => preco * quantidade;

  Compra copyWith({
    String? id,
    String? nome,
    double? preco,
    int? quantidade,
    Categoria? categoria,
    String? loja,
    DateTime? data,
    bool? marcado,
  }) {
    return Compra(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      preco: preco ?? this.preco,
      quantidade: quantidade ?? this.quantidade,
      categoria: categoria ?? this.categoria,
      loja: loja ?? this.loja,
      data: data ?? this.data,
      marcado: marcado ?? this.marcado,
    );
  }
}

// Representa o resumo de compras de um mes
class ResumoMes {
  final String mes;
  final int ano;
  final double totalGasto;
  final int totalCompras;
  final bool concluido;

  const ResumoMes({
    required this.mes,
    required this.ano,
    required this.totalGasto,
    required this.totalCompras,
    this.concluido = false,
  });

  // Label formatado para exibicao
  String get label => '$mes $ano';
}

// Agrupa compras por categoria para uso no grafico
class DadosCategoria {
  final Categoria categoria;
  final double percentual;
  final double total;

  const DadosCategoria({
    required this.categoria,
    required this.percentual,
    required this.total,
  });
}
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/produto_estoque.dart';
import '../models/compra.dart';

class ProdutoEstoqueService {
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

  ProdutoEstoque _mapParaProduto(Map<String, dynamic> map) {
    return ProdutoEstoque(
      id: map['id'] as String,
      usuarioId: map['usuario_id'] as String,
      nome: map['nome'] as String,
      categoria: _stringParaCategoria(map['categoria'] as String),
      quantidade: (map['quantidade'] as num).toDouble(),
      unidade: map['unidade'] as String,
      pesoUnitario: (map['peso_unitario'] as num).toDouble(),
      dataCompra: DateTime.parse(map['data_compra'] as String),
      mesAno: map['mes_ano'] as String,
      acabou: map['acabou'] as bool,
      proximaNotificacao: map['proxima_notificacao'] != null
          ? DateTime.parse(map['proxima_notificacao'] as String)
          : null,
      diasSnooze: map['dias_snooze'] as int? ?? 5,
    );
  }

  // Busca produtos que precisam ser notificados hoje
  Future<List<ProdutoEstoque>> buscarProdutosParaNotificar(String mesAno) async {
    final hoje = DateTime.now();
    final hojeStr = hoje.toIso8601String().substring(0, 10);

    final response = await _supabase
        .from('produtos_estoque')
        .select()
        .eq('usuario_id', _usuarioId)
        .eq('mes_ano', mesAno)
        .eq('acabou', false)
        .or('proxima_notificacao.is.null,proxima_notificacao.lte.$hojeStr');

    final produtos = (response as List)
        .map((m) => _mapParaProduto(m))
        .toList();

    // Ordena por prioridade: menor score = perguntar primeiro
    produtos.sort((a, b) => a.scorePrioridade.compareTo(b.scorePrioridade));

    return produtos;
  }

  // Busca todos os produtos do mês
  Future<List<ProdutoEstoque>> buscarProdutosMes(String mesAno) async {
    final response = await _supabase
        .from('produtos_estoque')
        .select()
        .eq('usuario_id', _usuarioId)
        .eq('mes_ano', mesAno)
        .order('criado_em', ascending: true);

    return (response as List).map((m) => _mapParaProduto(m)).toList();
  }

  // Adiciona produto ao estoque a partir de uma compra
  Future<ProdutoEstoque> adicionarProduto(ProdutoEstoque produto) async {
    // Notificação inicial: baseada no score de prioridade
    // Produtos mais leves/menos quantidade = notificar em 3 dias
    // Produtos mais pesados/mais quantidade = notificar em 7 dias
    final diasIniciais = _calcularDiasIniciais(produto);
    final proximaNotificacao = DateTime.now().add(Duration(days: diasIniciais));

    final data = {
      'usuario_id': _usuarioId,
      'nome': produto.nome,
      'categoria': _categoriaParaString(produto.categoria),
      'quantidade': produto.quantidade,
      'unidade': produto.unidade,
      'peso_unitario': produto.pesoUnitario,
      'data_compra': produto.dataCompra.toIso8601String().substring(0, 10),
      'mes_ano': produto.mesAno,
      'acabou': false,
      'proxima_notificacao': proximaNotificacao.toIso8601String().substring(0, 10),
      'dias_snooze': produto.diasSnooze,
    };

    final response = await _supabase
        .from('produtos_estoque')
        .insert(data)
        .select()
        .single();

    return _mapParaProduto(response);
  }

  // Calcula dias iniciais para primeira notificação baseado no peso e quantidade
  int _calcularDiasIniciais(ProdutoEstoque produto) {
    final pesoTotal = produto.quantidade * produto.pesoUnitario;

    if (pesoTotal < 500) return 3;       // menos de 500g/ml → perguntar em 3 dias
    if (pesoTotal < 1000) return 5;      // até 1kg/L → 5 dias
    if (pesoTotal < 3000) return 7;      // até 3kg/L → 7 dias
    if (pesoTotal < 6000) return 10;     // até 6kg/L → 10 dias
    return 14;                            // mais pesado → 14 dias
  }

  // Usuário respondeu "acabou"
  Future<void> marcarAcabou(String id) async {
    await _supabase
        .from('produtos_estoque')
        .update({'acabou': true})
        .eq('id', id)
        .eq('usuario_id', _usuarioId);
  }

  // Usuário respondeu "ainda não" — adia baseado no diasSnooze calculado
  Future<void> adiarNotificacao(String id, int dias) async {
    final proxima = DateTime.now().add(Duration(days: dias));
    await _supabase
        .from('produtos_estoque')
        .update({
          'proxima_notificacao': proxima.toIso8601String().substring(0, 10),
        })
        .eq('id', id)
        .eq('usuario_id', _usuarioId);
  }

  // Usuário respondeu "em 3 dias"
  Future<void> adiarTresDias(String id) async {
    await adiarNotificacao(id, 3);
  }

  // Remove todos os produtos do mês (ao fechar o mês)
  Future<void> removerProdutosMes(String mesAno) async {
    await _supabase
        .from('produtos_estoque')
        .delete()
        .eq('usuario_id', _usuarioId)
        .eq('mes_ano', mesAno);
  }
}
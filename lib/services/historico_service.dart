import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/compra.dart';

class HistoricoService {
  final _supabase = Supabase.instance.client;

  String get _usuarioId => _supabase.auth.currentUser!.id;

  ResumoMes _mapParaResumo(Map<String, dynamic> map) {
    return ResumoMes(
      mes: map['mes'] as String,
      ano: map['ano'] as int,
      totalGasto: (map['total_gasto'] as num).toDouble(),
      totalCompras: map['total_compras'] as int,
      concluido: map['concluido'] as bool,
    );
  }

  // Busca todo o historico do usuario
  Future<List<ResumoMes>> buscarHistorico() async {
    final response = await _supabase
        .from('resumo_mes')
        .select()
        .eq('usuario_id', _usuarioId)
        .order('ano', ascending: false)
        .order('criado_em', ascending: false);

    return (response as List).map((m) => _mapParaResumo(m)).toList();
  }

  // Salva o resumo do mes ao fechar
  Future<void> salvarResumoMes(ResumoMes resumo) async {
    await _supabase.from('resumo_mes').insert({
      'usuario_id': _usuarioId,
      'mes': resumo.mes,
      'ano': resumo.ano,
      'total_gasto': resumo.totalGasto,
      'total_compras': resumo.totalCompras,
      'concluido': resumo.concluido,
    });
  }
}
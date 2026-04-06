import 'package:flutter/material.dart';
import '../models/compra.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';

// Tela de historico exibindo o resumo de gastos por mes
class HistoricoScreen extends StatelessWidget {
  final List<ResumoMes> historico;
  final ValueChanged<ResumoMes>? onSelecionarMes;

  const HistoricoScreen({
    super.key,
    required this.historico,
    this.onSelecionarMes,
  });

  String _formatarValor(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    return 'R\$ ${partes[0]},${partes[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(titulo: 'Histórico'),
      body: historico.isEmpty ? _buildEstadoVazio() : _buildListaHistorico(),
    );
  }

  Widget _buildListaHistorico() {
    final Map<int, List<ResumoMes>> porAno = {};
    for (final mes in historico) {
      porAno.putIfAbsent(mes.ano, () => []).add(mes);
    }

    final anosOrdenados = porAno.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      itemCount: anosOrdenados.length,
      itemBuilder: (context, index) {
        final ano = anosOrdenados[index];
        final mesesDoAno = porAno[ano]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                ano.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: mesesDoAno.asMap().entries.map((entry) {
                    final i = entry.key;
                    final resumo = entry.value;
                    return Column(
                      children: [
                        _CardMes(
                          resumo: resumo,
                          formatarValor: _formatarValor,
                          onTap: () => onSelecionarMes?.call(resumo),
                        ),
                        if (i < mesesDoAno.length - 1)
                          const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: AppColors.border,
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildEstadoVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 56,
            color: AppColors.textTertiary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'Nenhum histórico disponível',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Feche o mês atual para ver o histórico aqui',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardMes extends StatelessWidget {
  final ResumoMes resumo;
  final String Function(double) formatarValor;
  final VoidCallback onTap;

  const _CardMes({
    required this.resumo,
    required this.formatarValor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resumo.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatarValor(resumo.totalGasto),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${resumo.totalCompras} compras',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (resumo.concluido)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.checkGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              )
            else
              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
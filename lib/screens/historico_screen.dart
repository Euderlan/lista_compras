import 'package:flutter/material.dart';
import '../models/compra.dart';
import '../theme/app_theme.dart';

// Tela de historico exibindo o resumo de gastos por mes
// com o valor total e numero de compras de cada periodo
class HistoricoScreen extends StatelessWidget {
  // Lista de resumos mensais para exibicao
  final List<ResumoMes> historico;

  // Callback ao tocar em um mes especifico
  final ValueChanged<ResumoMes>? onSelecionarMes;

  const HistoricoScreen({
    super.key,
    required this.historico,
    this.onSelecionarMes,
  });

  // Formata o valor como moeda brasileira
  String _formatarValor(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    return 'R\$ ${partes[0]},${partes[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header simples com titulo
          _buildHeader(),

          // Lista de meses ou estado vazio
          Expanded(
            child: historico.isEmpty
                ? _buildEstadoVazio()
                : _buildListaHistorico(),
          ),
        ],
      ),
    );
  }

  // Header com titulo "Historico" e safe area
  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historico',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Lista de cards de meses agrupados por ano
  Widget _buildListaHistorico() {
    // Agrupa os meses por ano
    final Map<int, List<ResumoMes>> porAno = {};
    for (final mes in historico) {
      porAno.putIfAbsent(mes.ano, () => []).add(mes);
    }

    // Ordena os anos de mais recente para mais antigo
    final anosOrdenados = porAno.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: anosOrdenados.length,
      itemBuilder: (context, index) {
        final ano = anosOrdenados[index];
        final mesesDoAno = porAno[ano]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label do ano
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
            // Cards dos meses deste ano
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
                        // Card de cada mes
                        _CardMes(
                          resumo: resumo,
                          formatarValor: _formatarValor,
                          onTap: () => onSelecionarMes?.call(resumo),
                        ),
                        // Separador entre meses (exceto o ultimo)
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

  // Exibido quando ainda nao ha historico registrado
  Widget _buildEstadoVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 56,
            color: AppColors.textTertiary.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'Nenhum historico disponivel',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Seus gastos mensais aparecerão aqui',
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

// Card de um mes individual no historico
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
            // Informacoes do mes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome do mes e ano
                  Text(
                    resumo.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Total gasto em verde
                  Text(
                    formatarValor(resumo.totalGasto),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Numero de compras
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
            // Icone de check (mes concluido) ou seta (mes ativo)
            if (resumo.concluido)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.checkGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
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
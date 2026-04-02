import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/compra.dart';
import '../theme/app_theme.dart';

// Grafico de pizza que exibe os gastos por categoria
class GraficoCategoria extends StatelessWidget {
  final List<DadosCategoria> dados;
  final double totalGasto;

  const GraficoCategoria({
    super.key,
    required this.dados,
    required this.totalGasto,
  });

  // Retorna a cor de cada categoria no grafico
  Color _corCategoria(Categoria categoria) {
    switch (categoria) {
      case Categoria.mercado:
        return AppColors.primaryDark;
      case Categoria.hortifruti:
        return AppColors.primaryLight;
      case Categoria.higiene:
        return AppColors.chartYellow;
      case Categoria.outros:
        return AppColors.chartGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Grafico de pizza
        SizedBox(
          width: 160,
          height: 160,
          child: CustomPaint(
            painter: _PieChartPainter(dados: dados, corCategoria: _corCategoria),
          ),
        ),
        const SizedBox(height: 16),
        // Legenda das categorias
        Wrap(
          spacing: 16,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: dados.map((dado) {
            return _ItemLegenda(
              cor: _corCategoria(dado.categoria),
              label: dado.categoria.nome,
              percentual: dado.percentual,
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Pintor customizado para o grafico de pizza
class _PieChartPainter extends CustomPainter {
  final List<DadosCategoria> dados;
  final Color Function(Categoria) corCategoria;

  const _PieChartPainter({
    required this.dados,
    required this.corCategoria,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final raio = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: centro, radius: raio);

    double anguloInicio = -math.pi / 2; // Comeca do topo

    final paint = Paint()..style = PaintingStyle.fill;

    for (final dado in dados) {
      final anguloFatia = 2 * math.pi * (dado.percentual / 100);

      paint.color = corCategoria(dado.categoria);
      canvas.drawArc(rect, anguloInicio, anguloFatia, true, paint);

      // Calcular posicao do texto da porcentagem
      final anguloMeio = anguloInicio + anguloFatia / 2;
      final raioPosicaoTexto = raio * 0.65;
      final posicaoTexto = Offset(
        centro.dx + raioPosicaoTexto * math.cos(anguloMeio),
        centro.dy + raioPosicaoTexto * math.sin(anguloMeio),
      );

      // Desenhar texto de porcentagem apenas se fatia for grande o suficiente
      if (dado.percentual > 8) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${dado.percentual.toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          posicaoTexto - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }

      anguloInicio += anguloFatia;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Item individual da legenda do grafico
class _ItemLegenda extends StatelessWidget {
  final Color cor;
  final String label;
  final double percentual;

  const _ItemLegenda({
    required this.cor,
    required this.label,
    required this.percentual,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: cor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ${percentual.toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
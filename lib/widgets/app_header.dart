import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Header padronizado usado em todas as telas principais do app
// Garante visual consistente: fundo primaryDark, texto branco, fonte 18 w600
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final List<Widget>? actions;
  final Widget? leading;
  final bool mostrarSafeArea;

  const AppHeader({
    super.key,
    required this.titulo,
    this.actions,
    this.leading,
    this.mostrarSafeArea = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      centerTitle: false,
      leading: leading,
      title: Text(
        titulo,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      actions: actions,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}

// Versao do header para telas modais (com botoes Cancelar/Salvar)
class AppHeaderModal extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final VoidCallback onCancelar;
  final VoidCallback onSalvar;
  final String labelSalvar;

  const AppHeaderModal({
    super.key,
    required this.titulo,
    required this.onCancelar,
    required this.onSalvar,
    this.labelSalvar = 'Salvar',
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Text(
        titulo,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      leadingWidth: 90,
      leading: TextButton(
        onPressed: onCancelar,
        child: const Text(
          'Cancelar',
          style: TextStyle(
            fontSize: 15,
            color: Colors.white70,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onSalvar,
          child: Text(
            labelSalvar,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
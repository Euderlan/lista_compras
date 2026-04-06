import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Servico central de autenticacao — email/senha e Google
class AuthService {
  final _supabase = Supabase.instance.client;

  // Retorna o usuario logado atualmente (null se nao logado)
  User? get usuarioAtual => _supabase.auth.currentUser;

  // Stream que emite eventos de mudanca de sessao
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Login com e-mail e senha
  Future<AuthResponse> entrarComEmail({
    required String email,
    required String senha,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: senha,
    );
  }

  // Cadastro com e-mail e senha
  Future<AuthResponse> cadastrarComEmail({
    required String nome,
    required String email,
    required String senha,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: senha,
      data: {'full_name': nome},
    );
  }

  // Login com Google
  Future<AuthResponse?> entrarComGoogle() async {
    final googleSignIn = GoogleSignIn(
      clientId:
          '181758554375-0s6hs54cbiq7vub0ncqor8lrcvc1eqmo.apps.googleusercontent.com',
      scopes: ['email', 'profile'],
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    if (googleAuth.accessToken == null || googleAuth.idToken == null) {
      throw Exception('Token do Google inválido');
    }

    return await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );
  }

  // Logout
  Future<void> sair() async {
    await _supabase.auth.signOut();
  }

  // Recuperar senha por e-mail
  Future<void> recuperarSenha(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}
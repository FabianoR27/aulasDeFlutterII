import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  // Guarda a inicialização para não repetir a configuração do Google.
  Future<void>? _googleSignInInitialization;

  bool carregando = false;
  String erro = '';

  // Retorna o usuário conectado no Firebase.
  User? get usuario => _firebaseAuth.currentUser;

  // Abre o login do Google e cria a sessão no aplicativo.
  Future<void> entrarComGoogle() async {
    if (carregando) return;
    carregando = true;
    erro = '';
    notifyListeners();

    try {
      if (kIsWeb) {
        await _firebaseAuth.signInWithPopup(GoogleAuthProvider());
      } else {
        _googleSignInInitialization ??= _googleSignIn.initialize(
          serverClientId: '928335484490-uhlc4pg87p599h8vng97plcp47i26e8i.apps.googleusercontent.com',
        );
        await _googleSignInInitialization;

        final conta = await _googleSignIn.authenticate();
        final idToken = conta.authentication.idToken;
        if (idToken == null || idToken.isEmpty) {
          throw StateError('O Google não retornou um token de autenticação.');
        }

        // O Firebase usa o token do Google para abrir a sessão do app.
        final credencial = GoogleAuthProvider.credential(idToken: idToken);
        await _firebaseAuth.signInWithCredential(credencial);
      }
    } catch (e) {
      erro = 'Não foi possível entrar com o Google: $e';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  // Fecha a sessão no Google e no Firebase.
  Future<void> deslogarUsuario() async {
    try {
      if (!kIsWeb) await _googleSignIn.signOut();
    } finally {
      await _firebaseAuth.signOut();
    }
  }
}

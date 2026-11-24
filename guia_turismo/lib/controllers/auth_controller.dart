import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:guia_turismo/utils/lugar_helpers.dart';

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
        // Inicializa o plugin do Google apenas uma vez com o ID do servidor Firebase.
        _googleSignInInitialization ??= _googleSignIn.initialize(
          serverClientId:
              '928335484490-uhlc4pg87p599h8vng97plcp47i26e8i.apps.googleusercontent.com',
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
    } on GoogleSignInException catch (e) {
      // Se a pessoa só fechou a janela do Google sem entrar, não precisa mostrar erro vermelho.
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        erro = '';
      } else {
        erro = 'Não foi possível entrar com sua conta Google. Tente novamente.';
      }
    } on FirebaseAuthException catch (e) {
      // Traduz os códigos mais comuns do Firebase pra mensagens fáceis de entender.
      erro = _traduzirErroFirebase(e.code);
    } catch (e) {
      erro = mensagemErroAmigavel(
        e,
        fallback: 'Não foi possível entrar com o Google. Tente novamente.',
      );
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  // Converte códigos técnicos do Firebase Auth em avisos simples pro usuário.
  String _traduzirErroFirebase(String codigo) {
    switch (codigo) {
      case 'network-request-failed':
        return 'Sem conexão com a internet. Verifique sua rede e tente novamente.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'account-exists-with-different-credential':
        return 'Já existe uma conta cadastrada com este e-mail usando outro método de login.';
      case 'popup-closed-by-user':
        return '';
      default:
        return 'Não foi possível concluir o login agora. Tente novamente.';
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

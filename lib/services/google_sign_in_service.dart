import 'package:google_sign_in/google_sign_in.dart';

sealed class GoogleSignInResult {}

class GoogleSignInSuccess extends GoogleSignInResult {
  final String idToken;
  GoogleSignInSuccess(this.idToken);
}

class GoogleSignInCancelled extends GoogleSignInResult {}

class GoogleSignInError extends GoogleSignInResult {
  final String message;
  GoogleSignInError(this.message);
}

class GoogleSignInService {
  static final GoogleSignInService instance = GoogleSignInService._();
  GoogleSignInService._();

  final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  Future<GoogleSignInResult> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return GoogleSignInCancelled();

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        return GoogleSignInError('Google authentication failed. Please try again.');
      }
      return GoogleSignInSuccess(idToken);
    } catch (e) {
      return GoogleSignInError('Google sign-in failed. Please try again.');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

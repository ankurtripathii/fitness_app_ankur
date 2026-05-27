import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handle(e);
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handle(e);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Authenticate the user (Replaces the old signIn method)
      // Note: If the user cancels the dialog, v7 throws a GoogleSignInException
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // 2. Get the ID Token (Authentication)
      // Note: In v7, .authentication is synchronous! Remove the 'await'
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 3. Request scopes to get the Access Token (Authorization)
      final clientAuth = await googleUser.authorizationClient.authorizeScopes([
        'email',
        'profile',
      ]);

      // 4. Create the Firebase Credential using tokens from BOTH steps
      final cred = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken, // Comes from the auth step
        accessToken: clientAuth.accessToken, // Comes from the scopes step!
      );

      // 5. Sign in to Firebase
      return await _auth.signInWithCredential(cred);
    } on GoogleSignInException catch (e) {
      // Handle the user closing the sign-in modal gracefully
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw _handle(e);
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  String _handle(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'Account already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}

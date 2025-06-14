import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Sign in with Google, returns Firebase ID token if successful
  Future<AuthResult> signInWithGoogle() async {
    try  {
      // ✅ Set Firebase language code
      FirebaseAuth.instance.setLanguageCode("en");

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google Sign-In aborted');
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);

      final idToken = await _firebaseAuth.currentUser?.getIdToken();

      final response = await _dio.post(
        'http://13.60.220.96:8000/auth/v5/firebase/signin',
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      final accessToken = response.data['data']['accessToken'];
      final displayName = _firebaseAuth.currentUser?.displayName ?? 'User';

      return AuthResult(accessToken: accessToken, displayName: displayName);
    } catch (e) {
      print ("e.toString()");
      print (e.toString());
      throw Exception("Google Sign-In failed: $e");

    }
  }


  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}

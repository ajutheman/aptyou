import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../models/auth_result_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Dio _dio = Dio();

  Future<AuthResult> signInWithGoogle() async {
    try {
      // Start Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In aborted');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);

      // Get Firebase ID token
      final idToken = await _firebaseAuth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception("No Firebase ID token");
      }

      // Get FCM token
      final fcmToken = await FirebaseMessaging.instance.getToken() ?? "unknown_fcm";

      // Get Device ID
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final deviceId = androidInfo.id ?? "unknown_device";

      // Send token to backend
      final response = await _dio.post(
        'http://13.60.220.96:8000/auth/v5/firebase/signin',
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
            'x-device-id': deviceId,
            'x-fcm-token': fcmToken,
            'x-secret-key': 'uG7pK2aLxX9zR1MvWq3EoJfHdTYcBn84',
          },
        ),
      );

      final accessToken = response.data['data']['accessToken'];
      final displayName = _firebaseAuth.currentUser?.displayName ?? 'User';

      return AuthResult(accessToken: accessToken, displayName: displayName);
    } catch (e) {
      throw Exception("Google Sign-In failed: $e");
    }
  }
}

// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'api_endpoints.dart';
//
// class DioClient {
//   static final Dio _dio = Dio(
//     BaseOptions(
//       baseUrl: ApiEndpoints.baseUrl,
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 10),
//       responseType: ResponseType.json,
//     ),
//   );
//
//   static Future<Dio> getClient({bool withAuth = true}) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken');
//     final fcmToken = prefs.getString('fcmToken') ?? 'dummy_fcm_token';
//     final deviceId = prefs.getString('deviceId') ?? 'dummy_device_id';
//
//     final headers = <String, String>{
//       'x-fcm-token': fcmToken,
//       'x-device-id': deviceId,
//       'x-secret-key': 'uG7pK2aLxX9zR1MvWq3EoJfHdTYcBn84',
//     };
//
//     if (withAuth && token != null) {
//       headers['Authorization'] = 'Bearer $token';
//     }
//
//     _dio.options.headers = headers;
//     return _dio;
//   }
// }
import 'package:dio/dio.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;

  DioClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: '',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ));
  }

  void setAccessToken(String token) {
    dio.options.headers["Authorization"] = "Bearer $token";
  }

  void setDefaultHeaders({
    required String firebaseToken,
    required String deviceId,
    required String fcmToken,
  }) {
    dio.options.headers = {
      "Authorization": "Bearer $firebaseToken",
      "x-device-id": deviceId,
      "x-fcm-token": fcmToken,
      "x-secret-key": "uG7pK2aLxX9zR1MvWq3EoJfHdTYcBn84",
    };
  }
}

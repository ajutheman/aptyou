// import 'package:dio/dio.dart';
// import '../../core/network/api_endpoints.dart';
// import '../../core/network/dio_client.dart';
//
// class ContentRepository {
//   final DioClient _client = DioClient();
//
//   Future<Map<String, dynamic>?> fetchAssets(String accessToken) async {
//     try {
//       _client.setAccessToken(accessToken);
//       final response = await _client.dio.get(ApiEndpoints.getSampleAssets);
//
//       if (response.statusCode == 200 && response.data['success'] == true) {
//         return response.data['data'];
//       }
//     } on DioException catch (e) {
//       print('Fetch asset error: ${e.message}');
//     }
//     return null;
//   }
// }
import 'package:dio/dio.dart';
import '../models/content_model.dart';

class ContentRepository {
  final Dio _dio = Dio();

  static const _url = 'http://13.60.220.96:8000/content/v5/sample-assets';

  Future<ContentModel> fetchContent(String accessToken) async {
    try {
      final response = await _dio.get(
        _url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success']) {
        return ContentModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load content');
      }
    } catch (e) {
      print('Content fetch error: $e');
      rethrow;
    }
  }
}

import 'package:dio/dio.dart';
import '../models/content_model.dart';

class ContentRepository {
  final Dio _dio = Dio();

  Future<ContentModel> fetchContent(String accessToken) async {
    try {
      final response = await _dio.get(
        'http://13.60.220.96:8000/content/v5/sample-assets',
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
      throw Exception('Error fetching content: $e');
    }
  }
}

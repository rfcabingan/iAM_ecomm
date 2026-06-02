import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';
import '../models/image_item.dart';

class ImagesApi {
  final ApiClient _client;
  ImagesApi(this._client);

  Future<ApiResponse<List<ImageItem>>> getImages({required String imageType}) {
    return _client.get<List<ImageItem>>(
      ApiEndpoints.images,
      queryParameters: {'imageType': imageType},
      fromJsonData: (data) => (data as List<dynamic>).map((item) => ImageItem.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }
}

import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';
import '../responses/response_prep.dart' show PointsHistoryItem, PointsBalanceData;

class PointsApi {
  PointsApi(this._client);

  final ApiClient _client;

  ApiResponse<T> _unauthorized<T>() {
    return ApiResponse<T>(
      status: 401,
      success: false,
      message: 'Authorization required. Please login again.',
      data: null,
    );
  }

  Future<ApiResponse<List<PointsHistoryItem>?>> getPoints() {
    if (!_client.hasAuthToken) return Future.value(_unauthorized<List<PointsHistoryItem>?>());
    return _client.get<List<PointsHistoryItem>?>(
      ApiEndpoints.points,
      fromJsonData: (dynamic v) {
        if (v is! List) return <PointsHistoryItem>[];
        return v.map((e) => PointsHistoryItem.fromJson(e)).whereType<PointsHistoryItem>().toList();
      },
    );
  }

  Future<ApiResponse<PointsBalanceData?>> getBalance() {
    if (!_client.hasAuthToken) return Future.value(_unauthorized<PointsBalanceData?>());
    return _client.get<PointsBalanceData?>(
      ApiEndpoints.pointsBalance,
      fromJsonData: PointsBalanceData.fromJson,
    );
  }
}

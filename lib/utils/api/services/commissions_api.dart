import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';
import '../responses/response_prep.dart';

class CommissionsApi {
  CommissionsApi(this._client);

  final ApiClient _client;

  ApiResponse<T> _unauthorized<T>() {
    return ApiResponse<T>(
      status: 401,
      success: false,
      message: 'Authorization required. Please login again.',
      data: null,
    );
  }

  /// GET `/Commissions/EcomSales/Total`
  Future<ApiResponse<EcomSalesCommissionTotalData?>> getEcomSalesTotal() {
    if (!_client.hasAuthToken) {
      return Future.value(_unauthorized<EcomSalesCommissionTotalData?>());
    }
    return _client.get<EcomSalesCommissionTotalData?>(
      ApiEndpoints.commissionsEcomSalesTotal,
      fromJsonData: EcomSalesCommissionTotalData.fromJson,
    );
  }

  /// GET `/Commissions/EcomSales/Details?days={days}`
  Future<ApiResponse<List<EcomSalesCommissionDetailItem?>>> getEcomSalesDetails({int days = 30}) {
    if (!_client.hasAuthToken) {
      return Future.value(_unauthorized<List<EcomSalesCommissionDetailItem?>>());
    }
    return _client.get<List<EcomSalesCommissionDetailItem?>>(
      ApiEndpoints.commissionsEcomSalesDetails,
      queryParameters: {
        'days': days,
      },
      fromJsonData: (dynamic v) {
        final list = v is List ? v : const [];
        return list
            .map((e) => EcomSalesCommissionDetailItem.fromJson(e))
            .whereType<EcomSalesCommissionDetailItem>()
            .toList();
      },
    );
  }
}

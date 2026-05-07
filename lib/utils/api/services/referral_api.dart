import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';
import '../responses/response_prep.dart';

class ReferralApi {
  ReferralApi(this._client);

  final ApiClient _client;

  Future<ApiResponse<ReferralData?>> getReferralById(String referralId) {
    return _client.get<ReferralData?>(
      ApiEndpoints.referralById(referralId),
      fromJsonData: (dynamic v) => ReferralData.fromJson(v),
    );
  }
}

import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';
import '../responses/response_prep.dart';

class ProfileApi {
  ProfileApi(this._client);

  final ApiClient _client;

  Future<ApiResponse<MemberPayload?>> getProfile() {
    return _client.get<MemberPayload?>(
      ApiEndpoints.profile,
      fromJsonData: MemberPayload.fromJson,
    );
  }
}

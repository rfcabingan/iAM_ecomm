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

  Future<ApiResponse<void>> deleteAccount({
    required int reasonId,
    required String reason,
  }) {
    return _client.delete<void>(
      ApiEndpoints.profileDeleteAccount,
      body: {
        'reasonId': reasonId,
        'reason': reason,
      },
      fromJsonData: (_) => null,
    );
  }

  Future<ApiResponse<List<DeleteAccountReasonItem?>>> getDeleteAccountReasons() {
    return _client.get<List<DeleteAccountReasonItem?>>(
      ApiEndpoints.profileDeleteAccountReasons,
      fromJsonData: (dynamic v) {
        if (v == null) return null;
        final list = v is List ? v : [];
        return list.map((e) => DeleteAccountReasonItem.fromJson(e)).toList();
      },
    );
  }
}

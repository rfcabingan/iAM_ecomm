import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';
import '../responses/response_prep.dart';

class PackagesApi {
  PackagesApi(this._client);

  final ApiClient _client;

  Future<ApiResponse<List<PackageItem?>>> getPackages() {
    return _client.get<List<PackageItem?>>(
      ApiEndpoints.packages,
      fromJsonData: (dynamic value) => _parseList(value, PackageItem.fromJson),
    );
  }

  Future<ApiResponse<List<PackageOptionItem?>>> getOptions(String packageCode) {
    return _client.get<List<PackageOptionItem?>>(
      ApiEndpoints.packageOptions(packageCode),
      fromJsonData: (dynamic value) =>
          _parseList(value, PackageOptionItem.fromJson),
    );
  }

  Future<ApiResponse<List<PackageOptionItemDetail?>>> getOptionItems({
    required String packageCode,
    required int optionId,
  }) {
    return _client.get<List<PackageOptionItemDetail?>>(
      ApiEndpoints.packageOptionItems(packageCode, optionId),
      fromJsonData: (dynamic value) =>
          _parseList(value, PackageOptionItemDetail.fromJson),
    );
  }

  Future<ApiResponse<PackageComputeFeesData?>> computeFees({
    required String packageCode,
    required int optionId,
    required int paymentMethodId,
    required int fulfillmentTypeId,
    required String country,
    required String province,
    required String city,
    required String barangay,
    String? areaCode,
  }) {
    return _client.post<PackageComputeFeesData?>(
      ApiEndpoints.packagesComputeFees,
      body: {
        'packageCode': packageCode,
        'optionId': optionId,
        'paymentMethodId': paymentMethodId,
        'fulfillmentTypeId': fulfillmentTypeId,
        'country': country,
        'province': province,
        'city': city,
        'barangay': barangay,
        'areaCode': areaCode,
      },
      fromJsonData: PackageComputeFeesData.fromJson,
    );
  }

  Future<ApiResponse<PackageRegistrationData?>> register({
    required String firstName,
    String? middleName,
    required String lastName,
    required String country,
    required String province,
    required String city,
    required String barangay,
    required String completeAddress,
    required String email,
    required String mobileNo,
    required String birthDate,
    required String gender,
    required String packageCode,
    required int optionId,
    required String sponsorIdno,
    required int paymentMethodId,
    required int fulfillmentTypeId,
    String? areaCode,
    required bool termsAccepted,
  }) {
    return _client.post<PackageRegistrationData?>(
      ApiEndpoints.packagesRegister,
      body: {
        'firstName': firstName,
        'middleName': middleName,
        'lastName': lastName,
        'country': country,
        'province': province,
        'city': city,
        'barangay': barangay,
        'completeAddress': completeAddress,
        'email': email,
        'mobileNo': mobileNo,
        'birthDate': birthDate,
        'gender': gender,
        'packageCode': packageCode,
        'optionId': optionId,
        'sponsorIdno': sponsorIdno,
        'paymentMethodId': paymentMethodId,
        'fulfillmentTypeId': fulfillmentTypeId,
        'areaCode': areaCode,
        'termsAccepted': termsAccepted,
      },
      fromJsonData: PackageRegistrationData.fromJson,
    );
  }

  static List<T?> _parseList<T>(dynamic value, T? Function(dynamic) fromJson) {
    final list = value is List ? value : const [];
    return list.map(fromJson).toList();
  }
}

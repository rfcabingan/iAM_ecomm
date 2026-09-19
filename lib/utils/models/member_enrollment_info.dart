class MemberEnrollmentInfo {
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String phone;
  final DateTime birthdate;
  final String gender;
  final String? idImagePath;
  final String? idImageBase64;
  final String? sponsorIdno;
  final int? paymentMethodId;
  final int? fulfillmentTypeId;
  final String? areaCode;
  final bool termsAccepted;

  MemberEnrollmentInfo({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.birthdate,
    required this.gender,
    this.idImagePath,
    this.idImageBase64,
    this.sponsorIdno,
    this.paymentMethodId,
    this.fulfillmentTypeId,
    this.areaCode,
    this.termsAccepted = false,
  });

  String get fullName => '$firstName $middleName $lastName'.trim();
}

class MemberEnrollmentInfo {
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String phone;
  final DateTime birthdate;
  final String gender;
  final String? idImagePath;

  MemberEnrollmentInfo({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.birthdate,
    required this.gender,
    this.idImagePath,
  });

  String get fullName => '$firstName $middleName $lastName'.trim();
}

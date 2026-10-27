class MemberSummary {
  final String id;
  final String givenName;
  final String? surname;
  final String email;
  final int role;
  MemberSummary({
    required this.id,
    required this.givenName,
    required this.surname,
    required this.email,
    required this.role,
  });
  String get fullName =>
      (surname == null || surname!.isEmpty) ? givenName : '$surname $givenName';
  factory MemberSummary.fromMap(Map<String, dynamic> map) {
    return MemberSummary(
      id: map['memberId'],
      givenName: map['givenName'],
      surname: map['surname'],
      email: map['email'],
      role: map['role'],
    );
  }
}
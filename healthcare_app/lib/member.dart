class Member{
  final String? id;
  final String email;
  final String password;
  final String givenName;
  final String? surname;
  final int role;
  Member({
    required this.id,
    required this.email,
    required this.password,
    required this.givenName,
    required this.surname,
    required this.role,
  });
  Map<String, Object?> toMap(){
    return{
      'memberId': id,
      'email': email,
      'password': password,
      'givenName': givenName,
      'surname': surname,
      'role': role,
    };
  }
}
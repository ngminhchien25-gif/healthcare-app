class LoginResponse{
  final bool success;
  final String? token;
  final String? message;
  LoginResponse({
    required this.success,
    required this.token,
    required this.message,
  });
  factory LoginResponse.fromMap(Map<String, dynamic> map){
    return LoginResponse(
      success: map['success'],
      token: map['token'],
      message: map['message'],
    );
  }
}
class Token {
  final String accessToken;
  final String tokenType;
  final int expiresIn;

  Token({required this.accessToken, required this.tokenType, required this.expiresIn});

  factory Token.fromJson(Map<String, dynamic> json) => Token(
    accessToken: json['access_token'],
    tokenType: json['token_type'],
    expiresIn: json['expires_in'] ?? 3600,
  );

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'token_type': tokenType,
    'expires_in': expiresIn,
  };
}

class UserCreate {
  final String email;
  final String password;
  final String fullName;

  UserCreate({required this.email, required this.password, required this.fullName});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'full_name': fullName,
  };
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class UserResponse {
  final String id;
  final String email;
  final String fullName;
  final bool isActive;
  final bool isSuperuser;
  final String createdAt;

  UserResponse({required this.id, required this.email, required this.fullName, required this.isActive, required this.isSuperuser, required this.createdAt});

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
    id: json['id'] ?? '',
    email: json['email'] ?? '',
    fullName: json['full_name'] ?? '',
    isActive: json['is_active'] ?? true,
    isSuperuser: json['is_superuser'] ?? false,
    createdAt: json['created_at'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'is_active': isActive,
    'is_superuser': isSuperuser,
    'created_at': createdAt,
  };
}

class HealthCheckResponse {
  final String status;
  final String projectName;
  final String version;
  final String environment;
  final String timestamp;

  HealthCheckResponse({required this.status, required this.projectName, required this.version, required this.environment, required this.timestamp});

  factory HealthCheckResponse.fromJson(Map<String, dynamic> json) => HealthCheckResponse(
    status: json['status'] ?? '',
    projectName: json['project_name'] ?? '',
    version: json['version'] ?? '',
    environment: json['environment'] ?? '',
    timestamp: json['timestamp'] ?? '',
  );
}

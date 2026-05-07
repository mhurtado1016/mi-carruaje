class AppException implements Exception {
  final String message;
  final int? statusCode;
  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([String message = 'Sin conexión a internet']) : super(message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException() : super('Sesión expirada', statusCode: 401);
}

class ServerException extends AppException {
  ServerException(String message, {int? statusCode}) : super(message, statusCode: statusCode);
}

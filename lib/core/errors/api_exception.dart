class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException({String? message})
      : super(
          message: message ?? 'No internet connection. Please check your network.',
        );
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({String? message})
      : super(
          message: message ?? 'Unauthorized. Please login again.',
          statusCode: 401,
        );
}

class NotFoundException extends ApiException {
  NotFoundException({String? message})
      : super(
          message: message ?? 'Resource not found.',
          statusCode: 404,
        );
}

class ValidationException extends ApiException {
  ValidationException({String? message, dynamic data})
      : super(
          message: message ?? 'Validation error.',
          statusCode: 400,
          data: data,
        );
}

class ServerException extends ApiException {
  ServerException({String? message})
      : super(
          message: message ?? 'Server error. Please try again later.',
          statusCode: 500,
        );
}

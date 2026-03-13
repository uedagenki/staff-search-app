class ApiResponse<T> {
  final T? data;
  final String? error;
  final String? message;
  final int statusCode;

  const ApiResponse._({
    this.data,
    this.error,
    this.message,
    required this.statusCode,
  });

  factory ApiResponse.success(T data, int statusCode) {
    return ApiResponse._(data: data, statusCode: statusCode);
  }

  factory ApiResponse.error(String error, String message, int statusCode) {
    return ApiResponse._(error: error, message: message, statusCode: statusCode);
  }

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

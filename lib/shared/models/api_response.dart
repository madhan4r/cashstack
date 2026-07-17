/// Mirrors the backend's `{ success, message, data }` response envelope.
///
/// Usage in a data source:
/// ```dart
/// final response = await dio.post('/auth/login', data: body);
/// final apiResponse = ApiResponse.fromJson(
///   response.data,
///   (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
/// );
/// return apiResponse.data;
/// ```
class ApiResponse<T> {
  final bool success;
  final String message;
  final T data;

  const ApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromData,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: fromData(json['data']),
    );
  }
}

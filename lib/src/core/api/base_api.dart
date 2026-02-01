import 'package:dio/dio.dart';
import '../utils/logger.dart';

/// Base API class for common error handling and response validation
abstract class BaseApi {
  /// Handles common API response validation
  /// Throws exception if status code is not 200
  /// Returns data cast to the specified type
  T handleResponse<T>(
    Response response,
    String operationName, {
    T Function(dynamic)? parser,
  }) {
    if (response.statusCode == 200) {
      logger.debug('$operationName: Success');
      if (parser != null) {
        return parser(response.data);
      }
      return response.data as T;
    }
    throw Exception('$operationName failed: ${response.statusCode}');
  }

  /// Handles API errors with consistent logging and error wrapping
  /// Returns appropriate exception based on error type
  Exception handleError(
    dynamic error,
    String operationName, {
    String Function(DioException)? dioErrorParser,
  }) {
    if (error is DioException) {
      logger.error('$operationName: DIO error', error);
      final message =
          dioErrorParser?.call(error) ?? error.message ?? 'Unknown error';
      return Exception('$operationName error: $message');
    }
    logger.error('$operationName: Unexpected error', error);
    return Exception('$operationName error: $error');
  }

  /// Wraps a Future operation with consistent error handling
  ///
  /// Usage:
  /// ```dart
  /// Future<T> myMethod() => executeApiCall(
  ///   'MyOperation',
  ///   () => _dio.post('/api/endpoint', data: {...}),
  ///   (response) => MyModel.fromJson(response.data),
  /// );
  /// ```
  Future<T> executeApiCall<T>(
    String operationName,
    Future<Response> Function() apiCall,
    T Function(Response) parser, {
    String Function(DioException)? dioErrorParser,
  }) async {
    try {
      logger.info('$operationName: Starting');
      final response = await apiCall();
      return handleResponse(
        response,
        operationName,
        parser: (_) => parser(response),
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw handleError(e, operationName, dioErrorParser: dioErrorParser);
    }
  }

  /// Similar to executeApiCall but for operations that don't return data (void operations)
  Future<void> executeApiCallVoid(
    String operationName,
    Future<Response> Function() apiCall, {
    String Function(DioException)? dioErrorParser,
  }) async {
    try {
      logger.info('$operationName: Starting');
      final response = await apiCall();
      handleResponse(response, operationName);
    } catch (e) {
      if (e is Exception) rethrow;
      throw handleError(e, operationName, dioErrorParser: dioErrorParser);
    }
  }

  /// Extract error message from DioException
  String extractDioErrorMessage(DioException error) {
    if (error.response?.statusCode == 404) {
      return 'Resource not found (404)';
    }
    if (error.response?.statusCode == 401) {
      return 'Unauthorized (401)';
    }
    if (error.response?.statusCode == 403) {
      return 'Forbidden (403)';
    }
    return error.message ?? 'Network error';
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/error/result.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/dio_exception_x.dart';

class FeedbackRepository {
  final Dio _dio;

  const FeedbackRepository(this._dio);

  Future<Result<void>> submit({
    required String message,
    Uint8List? screenshot,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/feedback',
        data: {
          'message': message,
          if (screenshot != null) 'screenshot': base64Encode(screenshot),
          'platform': _platformName,
        },
      );
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.err(mapExceptionToFailure(e.appException));
    }
  }

  String get _platformName {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'other';
  }
}

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepository(ref.watch(dioProvider));
});

import 'package:dio/dio.dart';
import '../../helpers/ExportImports.dart' hide Response; // Make sure this includes your User model

class ApiService {
  static const String _baseUrl = AppConstants.SERVER_URL;
  static const String _endPoint = '/api/';

  static String get bearerPrefix => 'Bearer ';

  static Future<String> resolveInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(AppConstants.REFRESH_TOKEN);

    if (refreshToken == null || refreshToken.isEmpty) {
      return AppRoutes.login;
    }

    final refreshed = await refreshAccessToken();

    if (refreshed) {
      return AppRoutes.dashboard;
    }

    await clearUserData();
    return AppRoutes.login;
  }


  static Future<bool> refreshAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(AppConstants.REFRESH_TOKEN);
      print('Attempting to refresh access token with refresh token: $refreshToken');

      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final dio = Dio();
      final url = '$_baseUrl${_endPoint}auth/refresh';

      final response = await dio.post(
        url,
        data: {
          'refresh_token': refreshToken, // MUST be a Map
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'];
        print('New access token received: $newAccessToken');

        await prefs.setString(
          AppConstants.ACCESS_TOKEN,
          newAccessToken,
        );

        return true;
      }

      return false;
    } on DioException {
      return false;
    }
  }


  static Future<String> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.ACCESS_TOKEN) ?? '';
    return token.isNotEmpty ? bearerPrefix + token : '';
  }

  static Future<void> saveTokensAndUser(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    print('access token: ${data['access_token']}');
    print('refresh token: ${data['refresh_token']}');
    await prefs.setString(AppConstants.ACCESS_TOKEN, data['access_token'] ?? '');
    await prefs.setString(AppConstants.REFRESH_TOKEN, data['refresh_token'] ?? '');

    final user = data['user'] as Map<String, dynamic>? ?? {};

    await prefs.setInt(AppConstants.USER_ID, user['id'] ?? 0);
    await prefs.setString(AppConstants.USER_USERNAME, user['username'] ?? '');
    await prefs.setString(AppConstants.USER_FULLNAME, user['full_name'] ?? '');
    await prefs.setString(AppConstants.USER_EMAIL, user['email'] ?? '');
    await prefs.setString(AppConstants.USER_ROLE, user['role'] ?? '');
    await prefs.setBool(AppConstants.IS_ONBOARDED, user['is_onboarded'] ?? false);
  }

  static Future<ActiveUser?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString(AppConstants.ACCESS_TOKEN);
    if (token == null || token.isEmpty) return null;

    return ActiveUser(
      message: 'Saved user',
      accessToken: token,
      refreshToken: prefs.getString(AppConstants.REFRESH_TOKEN) ?? '',
      user: ActiveUserClass(
        id: prefs.getInt(AppConstants.USER_ID) ?? 0,
        email: prefs.getString(AppConstants.USER_EMAIL) ?? '',
        username: prefs.getString(AppConstants.USER_USERNAME) ?? '',
        fullName: prefs.getString(AppConstants.USER_FULLNAME) ?? '',
        role: prefs.getString(AppConstants.USER_ROLE) ?? '',
        isOnboarded: prefs.getBool(AppConstants.IS_ONBOARDED) ?? false,
        timezone: null,
        phone: null,
        gender: null,
        createdAt: DateTime.now(),
      ),
    );
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.ACCESS_TOKEN);
    await prefs.remove(AppConstants.REFRESH_TOKEN);
    await prefs.remove(AppConstants.USER_ID);
    await prefs.remove(AppConstants.USER_USERNAME);
    await prefs.remove(AppConstants.USER_FULLNAME);
    await prefs.remove(AppConstants.USER_EMAIL);
    await prefs.remove(AppConstants.USER_ROLE);
    await prefs.remove(AppConstants.IS_ONBOARDED);
  }

  // ── LOGIN API ──
  static Future<ActiveUser?> login({
    required String email,
    required String password,
  }) async {
    try {
      final dio = Dio();
      final url = '$_baseUrl${_endPoint}auth/login';// Adjust endpoint if different

      final response = await dio.post(
        url,
        data: {
          'email': email.trim(),
          'password': password,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        // Save tokens & user
        await saveTokensAndUser(data);

        // Return parsed User model
        return ActiveUser.fromJson(data);
      }

      else {
        Get.snackbar(
          'Login Failed',
          response.data['message'] ?? 'Something went wrong',
          backgroundColor: grailErrorRed,
          colorText: Colors.white,
        );
        return null;
      }
    } on DioException catch (e) {
      String errorMsg = 'Something went wrong. Please try again.';

      if (e.response != null) {
        final status = e.response!.statusCode;
        // Use 'detail' if available, fallback to 'message'
        final msg = e.response!.data['detail'] ?? e.response!.data['message'] ?? '';

        if (status == 401 || status == 403 || status == 400) {
          // Show backend-provided message if exists
          errorMsg = msg.isNotEmpty ? msg : 'Invalid credentials. Please check your email/password.';
        } else if (status == 500) {
          errorMsg = 'Server error. Please try again later.';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMsg = 'Connection timeout. Please check your internet.';
      } else {
        errorMsg = 'No internet connection.';
      }

      // Show toast/snackbar with backend message
      Get.snackbar(
        'Login Failed',
        errorMsg,
        backgroundColor: grailErrorRed,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return null;
    }
  }

  // ── SEND OTP FOR PASSWORD RESET ──
  static Future<bool> sendOtpForReset({
    required String email,
  }) async {
    try {
      final dio = Dio();
      final url = '$_baseUrl${_endPoint}auth/forgot-password';

      final response = await dio.post(
        url,
        data: {'email': email.trim()},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final message = data['message'] as String? ?? 'OTP sent successfully';

        Get.snackbar(
          'Success',
          message,
          backgroundColor: grailGold,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );

        return true;
      } else {
        _showError(response.data['detail'] ?? response.data['message'] ?? 'Something went wrong');
        return false;
      }
    } on DioException catch (e) {
      String errorMsg = 'Something went wrong. Please try again.';

      if (e.response != null) {
        final msg = e.response!.data['detail'] ?? e.response!.data['message'] ?? '';
        if (e.response!.statusCode == 404) {
          errorMsg = msg.isNotEmpty ? msg : 'User not found with this email.';
        } else if (e.response!.statusCode == 400 || e.response!.statusCode == 422) {
          errorMsg = msg.isNotEmpty ? msg : 'Invalid email format.';
        } else {
          errorMsg = msg.isNotEmpty ? msg : 'Server error. Try again later.';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMsg = 'Connection timeout. Check your internet.';
      } else {
        errorMsg = 'No internet connection.';
      }

      _showError(errorMsg);
      return false;
    }
  }

  // Helper to show error snackbar
  static void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: grailErrorRed,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  // Add this method inside ApiService class

  static Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final dio = Dio();
      final url = '$_baseUrl${_endPoint}auth/reset-password';

      final response = await dio.post(
        url,
        data: {
          'email': email.trim(),
          'otp': otp.trim(),
          'new_password': newPassword,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final message = response.data is String
            ? response.data as String
            : response.data['message'] ?? 'Password reset successful!';

        Get.snackbar(
          'Success',
          message,
          backgroundColor: grailGold,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        return true;
      } else {
        _showResetError(response.data);
        return false;
      }
    } on DioException catch (e) {
      String errorMsg = 'Something went wrong. Please try again.';

      if (e.response != null) {
        final data = e.response!.data;
        if (e.response!.statusCode == 400) {
          errorMsg = data['detail'] ?? 'Invalid or expired OTP';
        } else if (e.response!.statusCode == 422) {
          // Validation error - extract first message
          if (data['detail'] is List && (data['detail'] as List).isNotEmpty) {
            final firstError = (data['detail'] as List).first;
            errorMsg = firstError['msg'] ?? 'Validation error';
          } else {
            errorMsg = 'Invalid input. Please check your details.';
          }
        } else {
          errorMsg = data['detail'] ?? data['message'] ?? 'Server error';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMsg = 'Connection timeout. Please check your internet.';
      } else {
        errorMsg = 'No internet connection.';
      }

      _showResetError(errorMsg);
      return false;
    }
  }

// Helper for reset-specific errors
  static void _showResetError(String message) {
    Get.snackbar(
      'Reset Failed',
      message,
      backgroundColor: grailErrorRed,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  Future<dynamic> callApiWithMap(
      String api,
      String requestType, {
        Map<String, dynamic>? queryParams,
        required Map<String, dynamic> mapData,
        bool getSnakcbar = true,
      }) async {
    Dio dio = Dio();
    // String url = '$_baseUrl$_endPoint$api';
    String url = '$_baseUrl$_endPoint$api';

    try {
      // Add authorization header if token exists
      String authHeader = await getAccessToken();
      if (authHeader.isNotEmpty) {
        dio.options.headers['Authorization'] = authHeader;
      }

      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      Response response;

      switch (requestType.toUpperCase()) {
        case 'GET':
          response = await dio.get(url, queryParameters: queryParams);
          break;
        case 'POST':
          response = await dio.post(url, data: mapData);
          break;
        case 'PUT':
          response = await dio.put(url, data: mapData);
          break;
        case 'DELETE':
          response = await dio.delete(url, data: mapData);
          break;
        default:
          throw Exception('Unsupported HTTP method: $requestType');
      }

      // Success: 200 or 201
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }

      // Server responded with error status
      _handleApiError(response, getSnakcbar: getSnakcbar);
      return null;

    } on DioException catch (e) {
      return _handleDioError(e, getSnakcbar: getSnakcbar);
    } catch (e) {
      Get.snackbar(
        'Unexpected Error',
        'Something went wrong. Please try again.',
        backgroundColor: grailErrorRed,
        colorText: Colors.white,
      );
      return null;
    }
  }

// Helper: Handle HTTP error responses (4xx, 5xx)
  void _handleApiError(Response response, {bool getSnakcbar = true}) {
    final statusCode = response.statusCode;

    if (statusCode == 401) {
      Get.snackbar(
        'Session Expired',
        'Please login again.',
        backgroundColor: grailErrorRed,
        colorText: Colors.white,
      );
      return;
    }

    String message = 'Request failed';
    if (response.data is Map && response.data.containsKey('message')) {
      message = response.data['message'];
    } else if (response.data is Map && response.data.containsKey('detail')) {
      message = response.data['detail'];
    }

    if (getSnakcbar) {
      Get.snackbar(
        'Error',
        message,
        backgroundColor: grailErrorRed,
        colorText: Colors.white,
      );
    }
  }

// Helper: Handle Dio exceptions (network, timeout, etc.)
  dynamic _handleDioError(DioException e, {bool getSnakcbar = true}) {
    if (e.response != null) {
      _handleApiError(e.response!, getSnakcbar: getSnakcbar);
      return null;
    }

    String message = 'No internet connection';

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timeout. Please try again.';
    } else if (e.type == DioExceptionType.badResponse) {
      message = 'Received invalid response from server.';
    }

    if (getSnakcbar) {
      Get.snackbar(
        'Network Error',
        message,
        backgroundColor: grailErrorRed,
        colorText: Colors.white,
      );
    }

    return null;
  }

}
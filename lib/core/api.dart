import 'dart:convert';

import 'package:http/http.dart' as http;

import 'session.dart';

class ApiException implements Exception {
  final int status;
  final String message;

  ApiException(this.status, this.message);

  @override
  String toString() => message;
}

class Api {
  static String baseUrl = 'http://localhost/minibank/api';

  static const String login = 'login.php';
  static const String logout = 'logout.php';
  static const String overview = 'overview.php';

  static const String adminStats = 'admin_stats.php';
  static const String adminUsers = 'admin_users.php';
  static const String adminUserBlock = 'admin_user_block.php';

  static const String adminCreditors = 'admin_creditors.php';
  static const String adminCreditorSave = 'admin_creditor_save.php';
  static const String adminCreditorDelete = 'admin_creditor_delete.php';
  static const String adminCreditorToggle = 'admin_creditor_toggle.php';

  static const String adminDepositProducts = 'admin_deposit_products.php';
  static const String adminDepositProductSave = 'admin_deposit_product_save.php';
  static const String adminDepositProductDelete =
      'admin_deposit_product_delete.php';
  static const String adminDepositProductToggle =
      'admin_deposit_product_toggle.php';

  static Future<Map<String, dynamic>> call(
    String endpoint, [
    Map<String, String> body = const <String, String>{},
  ]) async {
    final params = <String, String>{};
    params.addAll(body);

    final token = Session.token;
    if (token != null && token.isNotEmpty) {
      params['token'] = token;
    }

    http.Response response;
    try {
      response = await http
          .post(Uri.parse('$baseUrl/$endpoint'), body: params)
          .timeout(const Duration(seconds: 20));
    } catch (e) {
      throw ApiException(
        0,
        'Сервер не отвечает. Проверьте, что Apache и MySQL запущены, '
        'а адрес $baseUrl указан верно.',
      );
    }

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        response.statusCode,
        'Сервер вернул не JSON. Откройте $baseUrl/index.php в браузере '
        'и посмотрите на ошибку PHP.',
      );
    }

    final rawStatus = decoded['status'];
    final status = rawStatus is int ? rawStatus : int.tryParse('$rawStatus') ?? 0;
    final message = '${decoded['message'] ?? ''}';

    if (status != 200) {
      throw ApiException(status, message.isEmpty ? 'Ошибка $status' : message);
    }

    final data = decoded['data'];
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }
}

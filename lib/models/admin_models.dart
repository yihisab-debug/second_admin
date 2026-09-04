double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse('$value') ?? 0;
}

class AdminUser {
  final int id;
  final String fullName;
  final String phone;
  final String phonePretty;
  final bool isAdmin;
  final bool isBlocked;
  final String blockedReason;
  final String createdAt;
  final int walletsCount;
  final double balance;
  final int creditsCount;
  final int depositsCount;

  AdminUser({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.phonePretty,
    required this.isAdmin,
    required this.isBlocked,
    required this.blockedReason,
    required this.createdAt,
    required this.walletsCount,
    required this.balance,
    required this.creditsCount,
    required this.depositsCount,
  });

  String get initials {
    final parts = fullName.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
        id: _toInt(json['id']),
        fullName: '${json['full_name'] ?? ''}',
        phone: '${json['phone'] ?? ''}',
        phonePretty: '${json['phone_pretty'] ?? ''}',
        isAdmin: json['is_admin'] == true,
        isBlocked: json['is_blocked'] == true,
        blockedReason: '${json['blocked_reason'] ?? ''}',
        createdAt: '${json['created_at'] ?? ''}',
        walletsCount: _toInt(json['wallets_count']),
        balance: _toDouble(json['balance']),
        creditsCount: _toInt(json['credits_count']),
        depositsCount: _toInt(json['deposits_count']),
      );

  static List<AdminUser> listFrom(dynamic raw) {
    if (raw is! List) return <AdminUser>[];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((item) => AdminUser.fromJson(item))
        .toList();
  }
}

class AdminService {
  final int id;
  final String name;
  final String description;
  final double rate;
  final double minAmount;
  final double maxAmount;
  final int minMonths;
  final int maxMonths;
  final String currency;
  final bool isActive;
  final int usedCount;

  AdminService({
    required this.id,
    required this.name,
    required this.description,
    required this.rate,
    required this.minAmount,
    required this.maxAmount,
    required this.minMonths,
    required this.maxMonths,
    required this.currency,
    required this.isActive,
    required this.usedCount,
  });

  factory AdminService.fromJson(Map<String, dynamic> json) => AdminService(
        id: _toInt(json['id']),
        name: '${json['name'] ?? ''}',
        description: '${json['description'] ?? ''}',
        rate: _toDouble(json['rate']),
        minAmount: _toDouble(json['min_amount']),
        maxAmount: _toDouble(json['max_amount']),
        minMonths: _toInt(json['min_months']),
        maxMonths: _toInt(json['max_months']),
        currency: '${json['currency'] ?? 'KZT'}',
        isActive: json['is_active'] == true,
        usedCount: _toInt(json['used_count']),
      );

  static List<AdminService> listFrom(dynamic raw) {
    if (raw is! List) return <AdminService>[];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((item) => AdminService.fromJson(item))
        .toList();
  }
}

class AdminStats {
  final int usersTotal;
  final int usersBlocked;
  final int usersAdmins;
  final int walletsTotal;
  final double balanceKzt;
  final int creditorsTotal;
  final int creditorsActive;
  final int productsTotal;
  final int productsActive;
  final int creditsActive;
  final double creditsDebt;
  final int depositsActive;
  final double depositsAmount;

  AdminStats({
    required this.usersTotal,
    required this.usersBlocked,
    required this.usersAdmins,
    required this.walletsTotal,
    required this.balanceKzt,
    required this.creditorsTotal,
    required this.creditorsActive,
    required this.productsTotal,
    required this.productsActive,
    required this.creditsActive,
    required this.creditsDebt,
    required this.depositsActive,
    required this.depositsAmount,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) => AdminStats(
        usersTotal: _toInt(json['users_total']),
        usersBlocked: _toInt(json['users_blocked']),
        usersAdmins: _toInt(json['users_admins']),
        walletsTotal: _toInt(json['wallets_total']),
        balanceKzt: _toDouble(json['balance_kzt']),
        creditorsTotal: _toInt(json['creditors_total']),
        creditorsActive: _toInt(json['creditors_active']),
        productsTotal: _toInt(json['products_total']),
        productsActive: _toInt(json['products_active']),
        creditsActive: _toInt(json['credits_active']),
        creditsDebt: _toDouble(json['credits_debt']),
        depositsActive: _toInt(json['deposits_active']),
        depositsAmount: _toDouble(json['deposits_amount']),
      );

  static AdminStats empty() => AdminStats(
        usersTotal: 0,
        usersBlocked: 0,
        usersAdmins: 0,
        walletsTotal: 0,
        balanceKzt: 0,
        creditorsTotal: 0,
        creditorsActive: 0,
        productsTotal: 0,
        productsActive: 0,
        creditsActive: 0,
        creditsDebt: 0,
        depositsActive: 0,
        depositsAmount: 0,
      );
}

class AdminLogEntry {
  final int id;
  final String adminName;
  final String action;
  final String details;
  final String createdAt;

  AdminLogEntry({
    required this.id,
    required this.adminName,
    required this.action,
    required this.details,
    required this.createdAt,
  });

  String get actionLabel {
    switch (action) {
      case 'user_block':
        return 'Блокировка клиента';
      case 'user_unblock':
        return 'Разблокировка клиента';
      case 'service_create':
        return 'Добавлена услуга';
      case 'service_update':
        return 'Изменена услуга';
      case 'service_delete':
        return 'Удалена услуга';
      case 'service_enable':
        return 'Услуга включена';
      case 'service_disable':
        return 'Услуга отключена';
      default:
        return action;
    }
  }

  factory AdminLogEntry.fromJson(Map<String, dynamic> json) => AdminLogEntry(
        id: _toInt(json['id']),
        adminName: '${json['admin_name'] ?? ''}',
        action: '${json['action'] ?? ''}',
        details: '${json['details'] ?? ''}',
        createdAt: '${json['created_at'] ?? ''}',
      );

  static List<AdminLogEntry> listFrom(dynamic raw) {
    if (raw is! List) return <AdminLogEntry>[];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((item) => AdminLogEntry.fromJson(item))
        .toList();
  }
}

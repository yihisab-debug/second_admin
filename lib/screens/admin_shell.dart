import 'package:flutter/material.dart';

import '../core/api.dart';
import '../core/session.dart';
import '../core/theme.dart';
import 'login_screen.dart';
import 'admin_home_tab.dart';
import 'admin_services_tab.dart';
import 'admin_users_tab.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Выйти из панели администратора?'),
        content: const Text('Для повторного входа понадобится логин и пароль.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(110, 44),
              backgroundColor: AppColors.expense,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await Api.call(Api.logout);
    } on ApiException {
    }

    await Session.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = <String>[
      'Панель администратора',
      'Клиенты банка',
      'Кредитные программы',
      'Депозитные программы',
    ];

    final Widget body;
    switch (_index) {
      case 1:
        body = const AdminUsersTab();
        break;
      case 2:
        body = const AdminServicesTab(kind: ServiceKind.credit);
        break;
      case 3:
        body = const AdminServicesTab(kind: ServiceKind.deposit);
        break;
      default:
        body = const AdminHomeTab();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          IconButton(
            tooltip: 'Выйти',
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: AppColors.expense),
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: AppColors.primary.withValues(alpha: 0.1),
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          child: NavigationBar(
            height: 66,
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
                label: 'Обзор',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people, color: AppColors.primary),
                label: 'Клиенты',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_outlined),
                selectedIcon:
                    Icon(Icons.account_balance, color: AppColors.primary),
                label: 'Кредиты',
              ),
              NavigationDestination(
                icon: Icon(Icons.savings_outlined),
                selectedIcon: Icon(Icons.savings, color: AppColors.primary),
                label: 'Депозиты',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

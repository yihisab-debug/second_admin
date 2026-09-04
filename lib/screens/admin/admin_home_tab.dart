import 'package:flutter/material.dart';

import '../../core/api.dart';
import '../../core/format.dart';
import '../../core/session.dart';
import '../../core/theme.dart';
import '../../models/admin_models.dart';
import '../../widgets/app_widgets.dart';

class AdminHomeTab extends StatefulWidget {
  const AdminHomeTab({super.key});

  @override
  State<AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends State<AdminHomeTab> {
  AdminStats _stats = AdminStats.empty();
  List<AdminLogEntry> _log = <AdminLogEntry>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await Api.call(Api.adminStats);
      if (!mounted) return;
      final stats = data['stats'];
      setState(() {
        _stats = stats is Map<String, dynamic>
            ? AdminStats.fromJson(stats)
            : AdminStats.empty();
        _log = AdminLogEntry.listFrom(data['log']);
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showMessage(context, e.message, error: true);
    }
  }

  Widget _tile({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    String hint = '',
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
          if (hint.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              hint,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Session.fullName.isEmpty
                            ? 'Администратор'
                            : Session.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Полный доступ к услугам и клиентам',
                        style: TextStyle(color: Colors.white70, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionTitle(title: 'Показатели банка'),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
            children: [
              _tile(
                icon: Icons.people_alt_rounded,
                color: AppColors.primary,
                label: 'Клиентов всего',
                value: '${_stats.usersTotal}',
                hint: 'Администраторов: ${_stats.usersAdmins}',
              ),
              _tile(
                icon: Icons.block_rounded,
                color: AppColors.expense,
                label: 'Заблокировано',
                value: '${_stats.usersBlocked}',
              ),
              _tile(
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.income,
                label: 'Средства на счетах',
                value: formatMoney(_stats.balanceKzt, 'KZT', withCents: false),
                hint: 'Счетов: ${_stats.walletsTotal}',
              ),
              _tile(
                icon: Icons.account_balance_rounded,
                color: AppColors.accent,
                label: 'Выдано в кредит',
                value: formatMoney(_stats.creditsDebt, 'KZT', withCents: false),
                hint: 'Активных займов: ${_stats.creditsActive}',
              ),
              _tile(
                icon: Icons.savings_rounded,
                color: AppColors.primaryLight,
                label: 'На вкладах',
                value:
                    formatMoney(_stats.depositsAmount, 'KZT', withCents: false),
                hint: 'Открытых вкладов: ${_stats.depositsActive}',
              ),
              _tile(
                icon: Icons.list_alt_rounded,
                color: AppColors.text,
                label: 'Услуг в каталоге',
                value: '${_stats.creditorsTotal + _stats.productsTotal}',
                hint:
                    'Активных: ${_stats.creditorsActive + _stats.productsActive}',
              ),
            ],
          ),
          const SizedBox(height: 22),
          const SectionTitle(title: 'Последние действия'),
          const SizedBox(height: 8),
          if (_log.isEmpty)
            const EmptyState(
              icon: Icons.history_rounded,
              title: 'Журнал пуст',
              subtitle:
                  'Здесь появятся записи о добавлении услуг и блокировках клиентов.',
            )
          else
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < _log.length; i++) ...[
                    if (i > 0)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        _log[i].actionLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                      subtitle: Text(
                        _log[i].details.isEmpty
                            ? formatDateTime(_log[i].createdAt)
                            : '${_log[i].details} · ${formatDateTime(_log[i].createdAt)}',
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

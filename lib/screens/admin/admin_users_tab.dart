import 'package:flutter/material.dart';

import '../../core/api.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../models/admin_models.dart';
import '../../widgets/app_widgets.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final _searchController = TextEditingController();

  List<AdminUser> _users = <AdminUser>[];
  bool _loading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await Api.call(Api.adminUsers, {
        'q': _searchController.text.trim(),
        'filter': _filter,
      });
      if (!mounted) return;
      setState(() {
        _users = AdminUser.listFrom(data['users']);
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showMessage(context, e.message, error: true);
    }
  }

  Future<void> _block(AdminUser user) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Заблокировать клиента?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${user.fullName} потеряет доступ к приложению на всех устройствах. '
              'Счета и операции сохранятся.',
              style: const TextStyle(height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLength: 120,
              decoration: const InputDecoration(
                labelText: 'Причина блокировки',
                hintText: 'Например: подозрительные операции',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(130, 44),
              backgroundColor: AppColors.expense,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Заблокировать'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _sendBlock(user, true, reasonController.text.trim());
  }

  Future<void> _unblock(AdminUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Разблокировать клиента?'),
        content: Text('${user.fullName} снова сможет войти в приложение.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(130, 44),
              backgroundColor: AppColors.income,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Разблокировать'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _sendBlock(user, false, '');
  }

  Future<void> _sendBlock(AdminUser user, bool block, String reason) async {
    try {
      await Api.call(Api.adminUserBlock, {
        'user_id': '${user.id}',
        'block': block ? '1' : '0',
        'reason': reason,
      });
      if (!mounted) return;
      showMessage(
        context,
        block ? 'Клиент заблокирован' : 'Клиент разблокирован',
      );
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      showMessage(context, e.message, error: true);
    }
  }

  Widget _filterChip(String value, String label) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppColors.divider),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: selected ? Colors.white : AppColors.textMuted,
        ),
        onSelected: (_) {
          setState(() => _filter = value);
          _load();
        },
      ),
    );
  }

  Widget _userCard(AdminUser user) {
    final statusColor = user.isBlocked ? AppColors.expense : AppColors.income;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      user.initials,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.fullName.isEmpty ? 'Без имени' : user.fullName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                          if (user.isAdmin) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'админ',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.phonePretty,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatMoney(user.balance, 'KZT', withCents: false),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  user.isBlocked
                      ? Icons.lock_outline
                      : Icons.check_circle_outline,
                  size: 15,
                  color: statusColor,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    user.isBlocked
                        ? (user.blockedReason.isEmpty
                            ? 'Заблокирован'
                            : 'Заблокирован · ${user.blockedReason}')
                        : 'Активен · счетов: ${user.walletsCount}, '
                            'кредитов: ${user.creditsCount}, вкладов: ${user.depositsCount}',
                    style: TextStyle(fontSize: 12, color: statusColor),
                  ),
                ),
              ],
            ),
            if (!user.isAdmin) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    foregroundColor: statusColor,
                    side: BorderSide(color: statusColor.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    user.isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                    size: 18,
                  ),
                  label: Text(
                    user.isBlocked ? 'Разблокировать' : 'Заблокировать',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onPressed: () =>
                      user.isBlocked ? _unblock(user) : _block(user),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _load(),
            decoration: InputDecoration(
              hintText: 'Поиск по имени или телефону',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward, size: 20),
                onPressed: _load,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _filterChip('all', 'Все'),
              _filterChip('active', 'Активные'),
              _filterChip('blocked', 'Заблокированные'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _users.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 40),
                            EmptyState(
                              icon: Icons.person_search_outlined,
                              title: 'Клиенты не найдены',
                              subtitle:
                                  'Измените условия поиска или снимите фильтр.',
                            ),
                          ],
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          children: _users.map(_userCard).toList(),
                        ),
                ),
        ),
      ],
    );
  }
}

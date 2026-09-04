import 'package:flutter/material.dart';

import '../core/api.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../models/admin_models.dart';
import '../widgets/app_widgets.dart';
import 'admin_service_edit_screen.dart';

enum ServiceKind { credit, deposit }

class AdminServicesTab extends StatefulWidget {
  final ServiceKind kind;

  const AdminServicesTab({super.key, required this.kind});

  @override
  State<AdminServicesTab> createState() => _AdminServicesTabState();
}

class _AdminServicesTabState extends State<AdminServicesTab> {
  List<AdminService> _services = <AdminService>[];
  bool _loading = true;

  bool get _isCredit => widget.kind == ServiceKind.credit;

  String get _listEndpoint =>
      _isCredit ? Api.adminCreditors : Api.adminDepositProducts;
  String get _toggleEndpoint =>
      _isCredit ? Api.adminCreditorToggle : Api.adminDepositProductToggle;
  String get _deleteEndpoint =>
      _isCredit ? Api.adminCreditorDelete : Api.adminDepositProductDelete;

  String get _title => _isCredit ? 'кредитная программа' : 'вклад';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await Api.call(_listEndpoint);
      if (!mounted) return;
      setState(() {
        _services = AdminService.listFrom(data['services']);
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showMessage(context, e.message, error: true);
    }
  }

  Future<void> _openEditor([AdminService? service]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminServiceEditScreen(
          kind: widget.kind,
          service: service,
        ),
      ),
    );
    if (saved == true) await _load();
  }

  Future<void> _toggle(AdminService service) async {
    try {
      await Api.call(_toggleEndpoint, {
        'id': '${service.id}',
        'is_active': service.isActive ? '0' : '1',
      });
      if (!mounted) return;
      showMessage(
        context,
        service.isActive
            ? 'Услуга снята с продажи'
            : 'Услуга снова доступна клиентам',
      );
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      showMessage(context, e.message, error: true);
    }
  }

  Future<void> _delete(AdminService service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Удалить «${service.name}»?'),
        content: Text(
          service.usedCount > 0
              ? 'Услугой уже пользуются клиенты (${service.usedCount}), '
                  'поэтому она будет снята с продажи, а действующие договоры сохранятся.'
              : 'Услуга будет удалена из каталога без возможности восстановления.',
          style: const TextStyle(height: 1.4),
        ),
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
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await Api.call(_deleteEndpoint, {'id': '${service.id}'});
      if (!mounted) return;
      showMessage(context, 'Готово');
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      showMessage(context, e.message, error: true);
    }
  }

  Widget _serviceCard(AdminService service) {
    final color = service.isActive ? AppColors.income : AppColors.textMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _isCredit
                        ? Icons.account_balance_outlined
                        : Icons.savings_outlined,
                    color: AppColors.primary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        service.description.isEmpty
                            ? 'Без описания'
                            : service.description,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${service.rate.toStringAsFixed(2)} %',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isCredit ? 'ставка' : 'доходность',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _chip(
                  '${formatMoney(service.minAmount, service.currency, withCents: false)}'
                  ' — ${formatMoney(service.maxAmount, service.currency, withCents: false)}',
                ),
                _chip('${service.minMonths}–${service.maxMonths} мес.'),
                _chip('оформлено: ${service.usedCount}'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  service.isActive
                      ? Icons.check_circle_outline
                      : Icons.pause_circle_outline,
                  size: 15,
                  color: color,
                ),
                const SizedBox(width: 5),
                Text(
                  service.isActive ? 'Доступна клиентам' : 'Снята с продажи',
                  style: TextStyle(fontSize: 12, color: color),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Редактировать',
                  onPressed: () => _openEditor(service),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  tooltip: service.isActive ? 'Снять с продажи' : 'Включить',
                  onPressed: () => _toggle(service),
                  icon: Icon(
                    service.isActive
                        ? Icons.toggle_on_rounded
                        : Icons.toggle_off_rounded,
                    size: 26,
                    color: service.isActive
                        ? AppColors.income
                        : AppColors.textMuted,
                  ),
                ),
                IconButton(
                  tooltip: 'Удалить',
                  onPressed: () => _delete(service),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppColors.expense,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: Text(_isCredit ? 'Новый кредит' : 'Новый вклад'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _services.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 40),
                        EmptyState(
                          icon: Icons.playlist_add_rounded,
                          title: 'Список пуст',
                          subtitle:
                              'Нажмите «＋», чтобы добавить первую услугу — '
                              '$_title появится у клиентов сразу после сохранения.',
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                      children: _services.map(_serviceCard).toList(),
                    ),
            ),
    );
  }
}

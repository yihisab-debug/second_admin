import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/api.dart';
import '../../core/theme.dart';
import '../../models/admin_models.dart';
import '../../widgets/app_widgets.dart';
import 'admin_services_tab.dart';

class AdminServiceEditScreen extends StatefulWidget {
  final ServiceKind kind;
  final AdminService? service;

  const AdminServiceEditScreen({
    super.key,
    required this.kind,
    this.service,
  });

  @override
  State<AdminServiceEditScreen> createState() => _AdminServiceEditScreenState();
}

class _AdminServiceEditScreenState extends State<AdminServiceEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _rateController;
  late final TextEditingController _minAmountController;
  late final TextEditingController _maxAmountController;
  late final TextEditingController _minMonthsController;
  late final TextEditingController _maxMonthsController;

  static const Map<String, String> _currencies = <String, String>{
    'KZT': 'KZT ₸',
    'USD': 'USD \$',
    'EUR': 'EUR €',
  };

  String _currency = 'KZT';
  bool _isActive = true;
  bool _loading = false;

  bool get _isCredit => widget.kind == ServiceKind.credit;
  bool get _isNew => widget.service == null;

  String get _saveEndpoint =>
      _isCredit ? Api.adminCreditorSave : Api.adminDepositProductSave;

  @override
  void initState() {
    super.initState();
    final s = widget.service;

    _nameController = TextEditingController(text: s?.name ?? '');
    _descriptionController = TextEditingController(text: s?.description ?? '');
    _rateController = TextEditingController(
      text: s == null ? '' : s.rate.toStringAsFixed(2),
    );
    _minAmountController = TextEditingController(
      text: s == null ? '' : s.minAmount.toStringAsFixed(0),
    );
    _maxAmountController = TextEditingController(
      text: s == null ? '' : s.maxAmount.toStringAsFixed(0),
    );
    _minMonthsController = TextEditingController(
      text: s == null ? '' : '${s.minMonths}',
    );
    _maxMonthsController = TextEditingController(
      text: s == null ? '' : '${s.maxMonths}',
    );

    _currency = s?.currency ?? 'KZT';
    _isActive = s?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _rateController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    _minMonthsController.dispose();
    _maxMonthsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.length < 3) {
      showMessage(context, 'Введите название услуги', error: true);
      return;
    }

    setState(() => _loading = true);

    try {
      await Api.call(_saveEndpoint, {
        'id': '${widget.service?.id ?? 0}',
        'name': name,
        'description': _descriptionController.text.trim(),
        'rate': _rateController.text.trim(),
        'min_amount': _minAmountController.text.trim(),
        'max_amount': _maxAmountController.text.trim(),
        'min_months': _minMonthsController.text.trim(),
        'max_months': _maxMonthsController.text.trim(),
        'currency': _currency,
        'is_active': _isActive ? '1' : '0',
      });

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context, true);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(_isNew ? 'Услуга добавлена' : 'Изменения сохранены'),
            backgroundColor: AppColors.text,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
    } on ApiException catch (e) {
      if (!mounted) return;
      showMessage(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String suffix = '',
    bool decimal = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          decimal ? RegExp(r'[0-9.,]') : RegExp(r'[0-9]'),
        ),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix.isEmpty ? null : suffix,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _isNew
        ? (_isCredit ? 'Новая кредитная программа' : 'Новая программа вклада')
        : 'Редактирование услуги';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            AppCard(
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      _isCredit
                          ? Icons.account_balance_outlined
                          : Icons.savings_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isCredit
                          ? 'Программа появится в разделе «Кредиты» у всех клиентов банка.'
                          : 'Программа появится в разделе «Депозиты» у всех клиентов банка.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const SectionTitle(title: 'Основное'),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              maxLength: 80,
              decoration: InputDecoration(
                labelText: 'Название',
                hintText:
                    _isCredit ? 'MiniBank Классик' : 'Накопительный',
                counterText: '',
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _descriptionController,
              maxLength: 255,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Описание',
                hintText: 'Коротко о том, кому и зачем подходит услуга',
                counterText: '',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 18),
            const SectionTitle(title: 'Условия'),
            const SizedBox(height: 10),
            _numberField(
              controller: _rateController,
              label: _isCredit ? 'Годовая ставка' : 'Годовая доходность',
              hint: '18.90',
              suffix: '%',
              decimal: true,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _numberField(
                    controller: _minAmountController,
                    label: 'Сумма от',
                    hint: '30000',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _numberField(
                    controller: _maxAmountController,
                    label: 'Сумма до',
                    hint: '1500000',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _numberField(
                    controller: _minMonthsController,
                    label: 'Срок от',
                    hint: '6',
                    suffix: 'мес.',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _numberField(
                    controller: _maxMonthsController,
                    label: 'Срок до',
                    hint: '60',
                    suffix: 'мес.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Валюта',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: _currencies.entries.map((entry) {
                final selected = entry.key == _currency;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _currency = entry.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.divider,
                            width: selected ? 1.6 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Доступна клиентам',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.text,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Отключённая услуга остаётся в каталоге, '
                          'но клиент не сможет её оформить',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Switch(
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              label: _isNew ? 'Добавить услугу' : 'Сохранить изменения',
              loading: _loading,
              icon: _isNew ? Icons.add : Icons.save_outlined,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/api.dart';
import '../core/session.dart';
import '../core/theme.dart';
import '../widgets/app_widgets.dart';
import 'admin_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      showMessage(context, 'Введите телефон и пароль', error: true);
      return;
    }

    setState(() => _loading = true);

    try {
      final data = await Api.call(Api.login, {
        'phone': phone,
        'password': password,
      });

      final user = data['user'];
      final isAdmin = user is Map<String, dynamic> && user['is_admin'] == true;

      if (!isAdmin) {
        Session.token = '${data['token']}';
        try {
          await Api.call(Api.logout);
        } on ApiException {
        }
        await Session.clear();
        if (!mounted) return;
        showMessage(
          context,
          'У этой учётной записи нет прав администратора',
          error: true,
        );
        return;
      }

      Session.token = '${data['token']}';
      Session.userId = int.tryParse('${user['id']}') ?? 0;
      Session.fullName = '${user['full_name'] ?? ''}';
      Session.phone = '${user['phone'] ?? ''}';
      Session.isAdmin = true;
      await Session.save();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminShell()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      showMessage(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Панель администратора',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'MiniBank · управление услугами и клиентами',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14.5),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                      LengthLimitingTextInputFormatter(18),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Служебный телефон',
                      hintText: '+7 700 000 00 00',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    onSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(
                    label: 'Войти',
                    loading: _loading,
                    icon: Icons.login,
                    onPressed: _login,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Вход доступен только сотрудникам банка.\n'
                    'Клиентам — основное приложение MiniBank.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

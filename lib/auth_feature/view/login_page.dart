import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:school_app/auth_feature/service/supabase_auth.dart';
import 'package:school_app/auth_feature/view/Home_Page.dart';
import 'package:school_app/auth_feature/view/welcome.dart';

import 'forgot_password_page.dart';

/// Professional login screen with RTL/LTR awareness and Supabase integration.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final response = await SupabaseAuth().signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (response.user != null || response.session != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('login_success'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('login_failed'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff0D47A1), Color(0xff1976D2), Color(0xff63A4FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 90,
                                width: 90,
                                child: Image.asset('assets/images/1.png'),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'login'.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xff0D47A1),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'please_enter_email_and_password'.tr(),
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textAlign: isRtl ? TextAlign.right : TextAlign.left,
                          decoration: _inputDecoration(
                            icon: Icons.email_outlined,
                            label: 'email'.tr(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'required'.tr();
                            }
                            if (!value.contains('@')) {
                              return 'invalid_email'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textAlign: isRtl ? TextAlign.right : TextAlign.left,
                          decoration: _inputDecoration(
                            icon: Icons.lock_outline,
                            label: 'password'.tr(),
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (value) =>
                              value != null && value.length >= 6
                                  ? null
                                  : 'password_min_6'.tr(),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: isRtl
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: TextButton(
                            onPressed: _loading
                                ? null
                                : () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ForgotPasswordPage(),
                                      ),
                                    ),
                            child: Text(
                              'forget_password'.tr(),
                              style: const TextStyle(color: Color(0xff0D47A1)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff0D47A1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 4,
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'login'.tr(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'already_registered'.tr(),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                            TextButton(
                              onPressed: _loading
                                  ? null
                                  : () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const Welcome(),
                                        ),
                                      ),
                              child: Text(
                                'sign_up'.tr(),
                                style: const TextStyle(
                                  color: Color(0xff0D47A1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required IconData icon,
    required String label,
    Widget? suffix,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xff0D47A1)),
      suffixIcon: suffix,
      labelText: label,
      filled: true,
      fillColor: const Color(0xffF5F7FB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xff0D47A1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xffC5CAE9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xff0D47A1), width: 1.5),
      ),
      labelStyle: const TextStyle(color: Color(0xff0D47A1)),
    );
  }
}

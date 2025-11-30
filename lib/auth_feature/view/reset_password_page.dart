import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:school_app/auth_feature/service/supabase_auth.dart';
import 'package:school_app/auth_feature/view/login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _processing = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _processing = true);
    try {
      await SupabaseAuth().updatePassword(_passwordController.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('password_updated_msg'.tr())),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                centerTitle: true,
                title: Text(
                  'reset_password_title'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Icon(
                                  Icons.lock_open,
                                  size: 64,
                                  color: Color(0xff0D47A1),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'enter_new_password_instruction'.tr(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _hidePassword,
                                  textAlign:
                                      isRtl ? TextAlign.right : TextAlign.left,
                                  decoration: _inputDecoration(
                                    label: 'new_password'.tr(),
                                    icon: Icons.lock_outline,
                                    toggle: () =>
                                        setState(() => _hidePassword = !_hidePassword),
                                    obscured: _hidePassword,
                                  ),
                                  validator: (v) =>
                                      v != null && v.length >= 6
                                          ? null
                                          : 'password_min_6'.tr(),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _hideConfirmPassword,
                                  textAlign:
                                      isRtl ? TextAlign.right : TextAlign.left,
                                  decoration: _inputDecoration(
                                    label: 'confirm_new_password'.tr(),
                                    icon: Icons.lock_outline,
                                    toggle: () => setState(
                                        () => _hideConfirmPassword = !_hideConfirmPassword),
                                    obscured: _hideConfirmPassword,
                                  ),
                                  validator: (v) =>
                                      v == _passwordController.text
                                          ? null
                                          : 'passwords_not_match'.tr(),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _processing ? null : _resetPassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff0D47A1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: _processing
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            'reset_password_action'.tr(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required VoidCallback toggle,
    required bool obscured,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xff0D47A1)),
      suffixIcon: IconButton(
        icon: Icon(
          obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: const Color(0xff0D47A1),
        ),
        onPressed: toggle,
      ),
      labelText: label,
      filled: true,
      fillColor: const Color(0xffF5F7FB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
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

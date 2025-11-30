import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:school_app/auth_feature/service/supabase_auth.dart';
import 'package:school_app/auth_feature/view/Home_Page.dart';

/// Parent/Student signup screen with professional styling and RTL/LTR support.
class ParentSignUpPage extends StatefulWidget {
  const ParentSignUpPage({super.key});

  @override
  State<ParentSignUpPage> createState() => _ParentSignUpPageState();
}

class _ParentSignUpPageState extends State<ParentSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController conditionController = TextEditingController();

  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    gradeController.dispose();
    ageController.dispose();
    addressController.dispose();
    conditionController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final name = nameController.text.trim();
      final phone = phoneController.text.trim();
      final grade = gradeController.text.trim();
      final age = ageController.text.trim();
      final address = addressController.text.trim();
      final condition = conditionController.text.trim();

      await SupabaseAuth().signUpWithEmailPassword(
        email,
        password,
        UserType.student,
        metadata: {
          'name': name,
          'phone': phone,
          'grade': grade,
          'age': age,
          'address': address,
          'condition': condition,
          'email': email,
          'password': password,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('account_created'.tr()),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${'error_occurred'.tr()}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
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
                                child: Image.asset('assets/images/shcool_logo.png'),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'sign_up'.tr(),
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
                                'register'.tr(),
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildField(
                          controller: nameController,
                          label: 'full_name'.tr(),
                          icon: Icons.person_outline,
                          isRtl: isRtl,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'required'.tr() : null,
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: phoneController,
                          label: 'phone_number'.tr(),
                          icon: Icons.phone_outlined,
                          isRtl: isRtl,
                          keyboardType: TextInputType.phone,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'required'.tr() : null,
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: emailController,
                          label: 'email'.tr(),
                          icon: Icons.email_outlined,
                          isRtl: isRtl,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'required'.tr();
                            if (!v.contains('@')) return 'invalid_email'.tr();
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: passwordController,
                          label: 'password'.tr(),
                          icon: Icons.lock_outline,
                          isPassword: _hidePassword,
                          isRtl: isRtl,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (v) =>
                              v != null && v.length >= 6
                                  ? null
                                  : 'password_min_6'.tr(),
                          onSuffixTap: () =>
                              setState(() => _hidePassword = !_hidePassword),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                controller: gradeController,
                                label: 'grade'.tr(),
                                icon: Icons.school_outlined,
                                isRtl: isRtl,
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'required'.tr()
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                controller: ageController,
                                label: 'age'.tr(),
                                icon: Icons.cake_outlined,
                                isRtl: isRtl,
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'required'.tr()
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: addressController,
                          label: 'address'.tr(),
                          icon: Icons.location_on_outlined,
                          isRtl: isRtl,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'required'.tr() : null,
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: conditionController,
                          label: 'condition'.tr(),
                          icon: Icons.health_and_safety_outlined,
                          isRtl: isRtl,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'required'.tr() : null,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff0D47A1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 4,
                            ),
                            child: _isLoading
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
                                    'register'.tr(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: _isLoading ? null : () => Navigator.pop(context),
                            child: Text(
                              'login_here'.tr(),
                              style: const TextStyle(color: Color(0xff0D47A1)),
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
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isRtl,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool isPassword = false,
    VoidCallback? onSuffixTap,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: isRtl ? TextAlign.right : TextAlign.left,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xff0D47A1)),
        suffixIcon: onSuffixTap != null
            ? IconButton(
                icon: Icon(
                  isPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                ),
                onPressed: onSuffixTap,
              )
            : null,
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
      ),
    );
  }
}

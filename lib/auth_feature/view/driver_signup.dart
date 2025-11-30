// lib/auth_feature/view/driver_signup.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:school_app/auth_feature/service/supabase_auth.dart';
import 'package:school_app/auth_feature/view/Home_Page.dart';
import 'dart:ui' as ui;

import 'package:school_app/auth_feature/view/login_page.dart';

class BusDriverSignUpPage extends StatefulWidget {
  const BusDriverSignUpPage({super.key});

  @override
  State<BusDriverSignUpPage> createState() => _BusDriverSignUpPageState();
}

class _BusDriverSignUpPageState extends State<BusDriverSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    licenseController.dispose();
    emailController.dispose();
    passwordController.dispose();
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
      final license = licenseController.text.trim();

      await SupabaseAuth().signUpWithEmailPassword(
        email,
        password,
        UserType.driver,
        metadata: {
          'name': name,
          'phone': phone,
          'license_number': license,
          'email': email,
          'password': password,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('account_created'.tr()),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(e.toString())),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xff377FCC),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Logo
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/shcool_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Full Name
                _buildTextField(
                  controller: nameController,
                  label: 'full_name'.tr(),
                  icon: Icons.person_outline,
                  isRTL: isRTL,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'name_required'.tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Phone Number
                _buildTextField(
                  controller: phoneController,
                  label: 'phone_number'.tr(),
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  isRTL: isRTL,
                  textDirection: ui.TextDirection.ltr,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'valid_phone_required'.tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Driver License
                _buildTextField(
                  controller: licenseController,
                  label: 'driver_license'.tr(),
                  icon: Icons.badge_outlined,
                  isRTL: isRTL,
                  textDirection: ui.TextDirection.ltr,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'license_required'.tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Email
                _buildTextField(
                  controller: emailController,
                  label: 'email'.tr(),
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  isRTL: isRTL,
                  textDirection: ui.TextDirection.ltr,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'required'.tr();
                    }
                    if (!value.contains('@')) {
                      return 'valid_phone_required'.tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Password
                Directionality(
                  textDirection: isRTL
                      ? ui.TextDirection.rtl
                      : ui.TextDirection.ltr,
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'password'.tr(),
                      labelStyle: const TextStyle(
                        color: Color(0xffD7FD8C),
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xffD7FD8C),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xffD7FD8C),
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      filled: true,
                      fillColor: const Color(0xff135FCB),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xffD7FD8C),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xffD7FD8C),
                          width: 2.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.redAccent,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.redAccent,
                          width: 2.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'required'.tr();
                      }
                      if (value.length < 6) {
                        return 'password_min_6'.tr();
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 40),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff135FCB),
                      foregroundColor: const Color(0xffD7FD8C),
                      disabledBackgroundColor: const Color(
                        0xff135FCB,
                      ).withOpacity(0.6),
                      elevation: 8,
                      shadowColor: const Color(0xffD7FD8C).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xffD7FD8C),
                          width: 2,
                        ),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xffD7FD8C),
                              ),
                            ),
                          )
                        : Text(
                            'register'.tr(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  textDirection: isRTL
                      ? ui.TextDirection.rtl
                      : ui.TextDirection.ltr,
                  children: [
                    Text(
                      'already_registered'.tr(),
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      textDirection: isRTL
                          ? ui.TextDirection.rtl
                          : ui.TextDirection.ltr,
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.pushAndRemoveUntil(context, 
                        MaterialPageRoute(
                          builder: (_) => const LoginPage(),
                        ),
                        (route) => false,
                      ),
                      child: Text(
                        'login_here'.tr(),
                        style: const TextStyle(
                          color: Color(0xffD7FD8C),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          decoration: TextDecoration.underline,
                        ),
                        textDirection: isRTL
                            ? ui.TextDirection.rtl
                            : ui.TextDirection.ltr,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isRTL,
    TextInputType keyboardType = TextInputType.text,
    ui.TextDirection? textDirection,
    String? Function(String?)? validator,
  }) {
    return Directionality(
      textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        textDirection: textDirection,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xffD7FD8C), fontSize: 16),
          prefixIcon: Icon(icon, color: const Color(0xffD7FD8C)),
          filled: true,
          fillColor: const Color(0xff135FCB),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xffD7FD8C), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xffD7FD8C), width: 2.5),
            borderRadius: BorderRadius.circular(12),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent, width: 2.5),
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        validator: validator,
      ),
    );
  }
}

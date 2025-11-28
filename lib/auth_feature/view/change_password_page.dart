// lib/auth_feature/view/change_password_page.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String _userType = 'student';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('email') ?? '';
    _userType = prefs.getString('type') ?? 'student';
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<void> _changePassword() async {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('please_fill_all_fields'.tr()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('passwords_do_not_match'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('password_too_short'.tr()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final table = _userType == 'driver' ? 'driver_table' : 'student_table';
    final hashedOldPassword = _hashPassword(_hashPassword(oldPassword));

    try {
      final response = await Supabase.instance.client
          .from(table)
          .select('password')
          .eq('email', _userEmail)
          .maybeSingle();

      if (response == null || response['password'] != hashedOldPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('incorrect_old_password'.tr()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final hashedNewPassword = _hashPassword(_hashPassword(newPassword));
      await Supabase.instance.client
          .from(table)
          .update({'password': hashedNewPassword})
          .eq('email', _userEmail);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('password_changed_successfully'.tr()),
          backgroundColor: Colors.green,
        ),
      );

      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('error_changing_password'.tr() + ': $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff377FCC),
      appBar: AppBar(
        title: Text('change_password'.tr()),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xffD7FD8C)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Old Password Field
                TextField(
                  controller: _oldPasswordController,
                  obscureText: _obscureOldPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'old_password'.tr(),
                    labelStyle: const TextStyle(color: Color(0xffD7FD8C)),
                    filled: true,
                    fillColor: const Color(0xff135FCB),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xffD7FD8C)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xffD7FD8C), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureOldPassword ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xffD7FD8C),
                      ),
                      onPressed: () {
                        setState(() => _obscureOldPassword = !_obscureOldPassword);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // New Password Field
                TextField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'new_password'.tr(),
                    labelStyle: const TextStyle(color: Color(0xffD7FD8C)),
                    filled: true,
                    fillColor: const Color(0xff135FCB),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xffD7FD8C)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xffD7FD8C), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xffD7FD8C),
                      ),
                      onPressed: () {
                        setState(() => _obscureNewPassword = !_obscureNewPassword);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Confirm New Password Field
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'confirm_new_password'.tr(),
                    labelStyle: const TextStyle(color: Color(0xffD7FD8C)),
                    filled: true,
                    fillColor: const Color(0xff135FCB),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xffD7FD8C)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xffD7FD8C), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xffD7FD8C),
                      ),
                      onPressed: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Change Password Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Color(0xffD7FD8C), width: 2),
                      backgroundColor: const Color(0xff135FCB),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xff135FCB).withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      'change_password'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffD7FD8C),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
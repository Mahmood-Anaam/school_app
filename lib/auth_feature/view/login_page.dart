import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:school_app/auth_feature/service/supabase_auth.dart';
import 'package:school_app/auth_feature/view/welcome.dart';
import 'package:school_app/auth_feature/view/Home_Page.dart';

import 'forgot_password_page.dart';

/// Login screen.
/// Uses `SupabaseAuth` singleton to sign in users.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController(
    text: "eng.mahmood.anaam@gmail.com",
  );
  final TextEditingController passwordController = TextEditingController(
    text: "123456",
  );

  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('please_enter_email_and_password'.tr()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await SupabaseAuth().signInWithEmailPassword(email, password);

      if ((res.user != null) || (res.session != null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('login_success'.tr()),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        // Login failed without explicit error message from Supabase
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('login_failed'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff377FCC),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // App logo
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Center(
                    child: Image.asset("assets/images/1.png", scale: 0.1),
                  ),
                ),
                const SizedBox(height: 16),

                // App title
                Text(
                  "Hafelty+",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 24),

                // Email field
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'email'.tr(),
                    labelStyle: const TextStyle(color: Color(0xffD7FD8C)),
                    filled: true,
                    fillColor: const Color(0xff135FCB),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xffD7FD8C)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xffD7FD8C),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password field with visibility toggle
                Stack(
                  children: [
                    TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'password'.tr(),
                        labelStyle: const TextStyle(color: Color(0xffD7FD8C)),
                        filled: true,
                        fillColor: const Color(0xff135FCB),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xffD7FD8C),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xffD7FD8C),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    Positioned(
                      right: context.locale.languageCode == 'en' ? 12 : null,
                      left: context.locale.languageCode == 'ar' ? 12 : null,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xffD7FD8C),
                          size: 26,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Sign in button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xffD7FD8C),
                        width: 2,
                      ),
                      backgroundColor: const Color(0xff135FCB),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(
                        0xff135FCB,
                      ).withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'login'.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffD7FD8C),
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Forgot password link -> navigate to email input screen
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: Text(
                      'forget_password'.tr(),
                      style: const TextStyle(
                        color: Color(0xffD7FD8C),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Divider with "or"
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        endIndent: 10,
                        color: const Color(0xffD7FD8C),
                        thickness: 2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: Text(
                        "or".tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xffD7FD8C),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        indent: 10,
                        color: const Color(0xffD7FD8C),
                        thickness: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Sign up button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Welcome()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xffD7FD8C),
                        width: 2,
                      ),
                      foregroundColor: Color(0xffD7FD8C),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'sign_up'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
}

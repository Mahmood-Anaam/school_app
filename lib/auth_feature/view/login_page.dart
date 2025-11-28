import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_app/auth_feature/bloc/bloc/auth_bloc.dart';
import 'package:school_app/auth_feature/view/welcome.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:school_app/auth_feature/view/Home_Page.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // دالة لتشفير كلمة السر
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff377FCC),
      body: BlocListener<AuthBloc, AuthanticationState>(
        listener: (context, state) {
          if (state is Authanticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('login_success'.tr()),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('error'.tr(args: [state.message])),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // شعار التطبيق
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Center(
                      child: Image.asset("assets/images/1.png", scale: 0.1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // اسم التطبيق بخط أنيق
                  Text(
                    "Hafelty+",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      fontFamily: 'Roboto', // يمكن تغييره لأي خط مناسب
                    ),
                  ),
                  const SizedBox(height: 24),
                  // حقل البريد الإلكتروني
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
                        borderSide: const BorderSide(color: Color(0xffD7FD8C), width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // حقل كلمة المرور مع أيقونة الرؤية
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
                            borderSide: const BorderSide(color: Color(0xffD7FD8C)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xffD7FD8C), width: 2),
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
                  // زر تسجيل الدخول
                  SizedBox(
                    width: double.infinity,
                    child: BlocBuilder<AuthBloc, AuthanticationState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoding;
                        return ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
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

                            final hashedPassword = _hashPassword(password);

                            context.read<AuthBloc>().add(
                              LoginEvent(
                                email: email,
                                password: hashedPassword,
                              ),
                            );
                          },
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
                          child: isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                        );
                      },
                    ),
                  ),

                  // رابط نسيت كلمة المرور
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ForgotPasswordPage()),
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
                          style: const TextStyle(fontSize: 18, color: Color(0xffD7FD8C)),
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
                  // زر التسجيل
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
                        side: const BorderSide(color: Color(0xffD7FD8C), width: 2),
                        foregroundColor: Color(0xffD7FD8C),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'sign_up'.tr(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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

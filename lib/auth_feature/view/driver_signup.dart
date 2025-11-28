import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:school_app/auth_feature/bloc/bloc/auth_bloc.dart';
import 'package:school_app/auth_feature/view/Home_Page.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class BusDriverSignUpPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  BusDriverSignUpPage({super.key});

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocListener<AuthBloc, AuthanticationState>(
        listener: (context, state) {
          if (state is AuthLoding) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('creating_account'.tr()),
                backgroundColor: Colors.blueAccent,
              ),
            );
          } else if (state is Authanticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('account_created'.tr()),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${'error_occurred'.tr()}: ${state.message}'),
                backgroundColor: Colors.red,
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
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Center(
                      child: Image.asset("assets/images/shcool_logo.png"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  buildTextField(controller: nameController, label: 'full_name'.tr()),
                  const SizedBox(height: 20),
                  buildTextField(controller: phoneController, label: 'phone_number'.tr(), keyboardType: TextInputType.phone),
                  const SizedBox(height: 20),
                  buildTextField(controller: licenseController, label: 'driver_license'.tr()),
                  const SizedBox(height: 20),
                  buildTextField(controller: emailController, label: 'email'.tr(), keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  buildTextField(controller: passwordController, label: 'password'.tr(), isPassword: true),
                  const SizedBox(height: 30),
                  BlocBuilder<AuthBloc, AuthanticationState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoding;
                      return ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                          final hashedPassword = _hashPassword(passwordController.text.trim());
                          context.read<AuthBloc>().add(
                            SignUpDriverEvent(
                              name: nameController.text.trim(),
                              phone: phoneController.text.trim(),
                              license: licenseController.text.trim(),
                              email: emailController.text.trim(),
                              password: hashedPassword,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff135FCB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.white),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                            : Text(
                          'register'.tr(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("already_registered".tr(), style: const TextStyle(color: Color(0xffD7FD8C))),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text('login_here'.tr(), style: const TextStyle(color: Color(0xffD7FD8C), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xffD7FD8C)),
        filled: true,
        fillColor: const Color(0xff135FCB),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xffD7FD8C)), borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xffD7FD8C)), borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
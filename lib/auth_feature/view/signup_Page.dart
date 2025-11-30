import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:school_app/auth_feature/service/supabase_auth.dart';
import 'package:school_app/auth_feature/view/Home_Page.dart';

/// Parent/Student signup screen.
/// Collects parent information and creates a new account using Supabase.
class ParentSignUpPage extends StatefulWidget {
  const ParentSignUpPage({super.key});

  @override
  State<ParentSignUpPage> createState() => _ParentSignUpPageState();
}

class _ParentSignUpPageState extends State<ParentSignUpPage> {
  final TextEditingController nameController = TextEditingController(text: "Mahmood Anaam");
  final TextEditingController phoneController = TextEditingController(text: "01090000000");
  final TextEditingController emailController = TextEditingController(text: "eng.mahmood.anaam@gmail.com");
  final TextEditingController passwordController = TextEditingController(text: "123456");
  final TextEditingController gradeController = TextEditingController(text: "5");
  final TextEditingController ageController = TextEditingController(text: "10");
  final TextEditingController addressController = TextEditingController(text: "taiz");
  final TextEditingController conditionController = TextEditingController(text: "good");

  bool _isLoading = false;

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

  /// Perform student signup using Supabase.
  Future<void> _signUp() async {
    if (!_validateInputs()) {
      _showErrorSnackBar('${'error_occurred'.tr()}: Invalid input');
      return;
    }

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

      // Signup with Supabase Auth
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

      _showSuccessSnackBar('account_created'.tr());

      // Navigate to home after successful signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('${'error_occurred'.tr()}: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Validate all required input fields.
  bool _validateInputs() {
    return nameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        gradeController.text.isNotEmpty &&
        ageController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        conditionController.text.isNotEmpty;
  }

  /// Show success message using SnackBar.
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  /// Show error message using SnackBar.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    child: Image.asset('assets/images/shcool_logo.png'),
                  ),
                ),
                const SizedBox(height: 10),
                // Full name field
                _buildTextField(
                  controller: nameController,
                  label: 'full_name'.tr(),
                ),
                const SizedBox(height: 20),
                // Phone number field
                _buildTextField(
                  controller: phoneController,
                  label: 'phone_number'.tr(),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                // Email field
                _buildTextField(
                  controller: emailController,
                  label: 'email'.tr(),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                // Password field
                _buildTextField(
                  controller: passwordController,
                  label: 'password'.tr(),
                  isPassword: true,
                ),
                const SizedBox(height: 20),
                // Grade field
                _buildTextField(
                  controller: gradeController,
                  label: 'grade'.tr(),
                ),
                const SizedBox(height: 20),
                // Age field
                _buildTextField(controller: ageController, label: 'age'.tr()),
                const SizedBox(height: 20),
                // Address field
                _buildTextField(
                  controller: addressController,
                  label: 'address'.tr(),
                ),
                const SizedBox(height: 20),
                // Health condition field
                _buildTextField(
                  controller: conditionController,
                  label: 'condition'.tr(),
                ),
                const SizedBox(height: 30),
                // Sign-up button
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff135FCB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 50,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.white),
                    ),
                  ),
                  child: _isLoading
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
                          'register'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 30),
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'already_registered'.tr(),
                      style: const TextStyle(color: Color(0xffD7FD8C)),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'login_here'.tr(),
                        style: const TextStyle(
                          color: Color(0xffD7FD8C),
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
    );
  }

  /// Build a reusable text input field.
  Widget _buildTextField({
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
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xffD7FD8C)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xffD7FD8C)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

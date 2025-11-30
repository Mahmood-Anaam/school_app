// lib/auth_feature/view/edit_profile.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:school_app/auth_feature/service/supabase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = true;
  int? _userId;
  String _userType = 'student';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController conditionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    // Get the current user from the SupabaseAuth singleton
    final currentUser = await SupabaseAuth().getCurrentUser();

    if (currentUser == null || currentUser.email == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final email = currentUser.email!;
    final metadata = currentUser.userMetadata ?? <String, dynamic>{};
    final type = (metadata['type'] as String?) ?? 'student';

    _userType = type;
    final table = type == 'driver' ? 'driver_table' : 'student_table';

    try {
      final response = await _supabase
          .from(table)
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response != null) {
        _userId = (response['id'] as num?)?.toInt();
        nameController.text = response['name'] ?? '';
        phoneController.text = response['phone'] ?? '';
        emailController.text = response['email'] ?? '';

        if (_userType == 'driver') {
          licenseController.text = response['license_number'] ?? '';
        } else {
          gradeController.text = response['grade'] ?? '';
          ageController.text = response['age'] ?? '';
          addressController.text = response['address'] ?? '';
          conditionController.text = response['condition'] ?? '';
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('user_data_not_found'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final table = _userType == 'driver' ? 'driver_table' : 'student_table';
    final data = {
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'email': emailController.text.trim(),
    };

    if (_userType == 'driver') {
      data['license_number'] = licenseController.text.trim();
    } else {
      data['grade'] = gradeController.text.trim();
      data['age'] = ageController.text.trim();
      data['address'] = addressController.text.trim();
      data['condition'] = conditionController.text.trim();
    }

    try {
      await _supabase.from(table).update(data).eq('id', _userId!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile_updated_successfully'.tr()),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${'error_occurred'.tr()}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff377FCC),
      appBar: AppBar(
        title: Text('edit_profile'.tr()),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xffD7FD8C)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'name'.tr(),
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
                      const SizedBox(height: 20),
                      TextField(
                        controller: phoneController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'phone'.tr(),
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
                      const SizedBox(height: 20),
                      TextField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'email'.tr(),
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
                      const SizedBox(height: 20),
                      if (_userType == 'driver')
                        TextField(
                          controller: licenseController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'license_number'.tr(),
                            labelStyle: const TextStyle(
                              color: Color(0xffD7FD8C),
                            ),
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
                      if (_userType == 'student') ...[
                        TextField(
                          controller: gradeController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'grade'.tr(),
                            labelStyle: const TextStyle(
                              color: Color(0xffD7FD8C),
                            ),
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
                        const SizedBox(height: 20),
                        TextField(
                          controller: ageController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'age'.tr(),
                            labelStyle: const TextStyle(
                              color: Color(0xffD7FD8C),
                            ),
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
                        const SizedBox(height: 20),
                        TextField(
                          controller: addressController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'address'.tr(),
                            labelStyle: const TextStyle(
                              color: Color(0xffD7FD8C),
                            ),
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
                        const SizedBox(height: 20),
                        TextField(
                          controller: conditionController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'condition'.tr(),
                            labelStyle: const TextStyle(
                              color: Color(0xffD7FD8C),
                            ),
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
                      ],
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateProfile,
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
                          child: Text(
                            'save_changes'.tr(),
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
}

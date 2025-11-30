import 'package:supabase_flutter/supabase_flutter.dart';

enum UserType { student, driver }

class SupabaseAuth {
  // Singleton: single shared instance for the app
  static final SupabaseAuth _instance = SupabaseAuth._internal();
  factory SupabaseAuth() => _instance;
  SupabaseAuth._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signInWithPassword(
      password: password,
      email: email,
    );
  }

  // sign Up with email and password
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
    UserType userType, {
    Map<String, dynamic> metadata = const {},
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'type': userType.name},
    );

    await _supabase
        .from(userType == UserType.student ? 'student_table' : 'driver_table')
        .insert({...metadata});

    return response;
  }

  // sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // send OTP to email for password reset
  Future<void> sendOtp(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // verify OTP code
  Future<void> verifyOtp(String otp, String email) async {
    await _supabase.auth.verifyOTP(
      type: OtpType.recovery,
      email: email,
      token: otp,
    );
  }

  // update password
  Future<void> updatePassword(String newPassword) async {
    final response = await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    await _supabase
        .from(
          response.user!.userMetadata!['type'] == UserType.student.name
              ? 'student_table'
              : 'driver_table',
        )
        .update({'password': newPassword})
        .eq('email', response.user!.email!);
  }

  // check if user is authenticated
  Future<bool> isAuthenticated() async {
    final session = _supabase.auth.currentSession;
    return session != null;
  }

  // get current user
  Future<User?> getCurrentUser() async {
    return _supabase.auth.currentUser;
  }

  Future<UserType?> getCurrentUserType() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final type = user.userMetadata!['type'] == UserType.student.name
          ? UserType.student
          : UserType.driver;
      return type;
    }

    return null;
  }
}

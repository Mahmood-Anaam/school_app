//lib/auth_feature/service/supabase_auth.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuth {
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
  ) async {
    return await _supabase.auth.signUp(password: password, email: email);
  }

  // sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  //get current user email
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}

// lib/auth_feature/bloc/bloc/auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart'; // لـ hash كلمة المرور
import 'dart:convert'; // لـ utf8.encode
import 'package:shared_preferences/shared_preferences.dart'; // لتخزين الجلسة

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthanticationState> {
  final SupabaseClient supabase;

  AuthBloc({required this.supabase}) : super(AuthInitial()) {
    on<ChecAuthanticated>((event, emit) async {
      emit(AuthLoding());
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');
      final type = prefs.getString('type');

      if (email != null && type != null) {
        Map<String, dynamic>? userData;
        if (type == 'student') {
          userData = await supabase.from('student_table').select().eq('email', email).maybeSingle();
        } else if (type == 'driver') {
          userData = await supabase.from('driver_table').select().eq('email', email).maybeSingle();
        }
        if (userData != null) {
          emit(Authanticated(type: type, userData: userData));
        } else {
          emit(Unauthanticated());
        }
      } else {
        emit(Unauthanticated());
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoding());
      try {
        // hash كلمة المرور
        final hashedPassword = sha256.convert(utf8.encode(event.password)).toString();

        // تحقق في student_table
        var res = await supabase.from('student_table').select().eq('email', event.email).eq('password', hashedPassword).maybeSingle();
        if (res != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', event.email);
          await prefs.setString('type', 'student');
          emit(Authanticated(type: 'student', userData: res));
          return;
        }

        // تحقق في driver_table
        res = await supabase.from('driver_table').select().eq('email', event.email).eq('password', hashedPassword).maybeSingle();
        if (res != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', event.email);
          await prefs.setString('type', 'driver');
          emit(Authanticated(type: 'driver', userData: res));
          return;
        }

        emit(AuthError(message: "Wrong Email Or Password"));
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    });

    on<LogoutEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      emit(AuthLogout());
    });

    on<SignUpDriverEvent>((event, emit) async {
      emit(AuthLoding());
      try {
        // تحقق إذا كان البريد موجودًا
        final existing = await supabase.from('driver_table').select().eq('email', event.email).maybeSingle();
        if (existing != null) {
          emit(AuthError(message: "Email already exists"));
          return;
        }

        // hash كلمة المرور
        final hashedPassword = sha256.convert(utf8.encode(event.password)).toString();

        await supabase.from('driver_table').insert({
          'name': event.name,
          'phone': event.phone,
          'license_number': event.license,
          'email': event.email,
          'password': hashedPassword,
        });

        final userData = await supabase.from('driver_table').select().eq('email', event.email).single();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', event.email);
        await prefs.setString('type', 'driver');
        emit(Authanticated(type: 'driver', userData: userData));
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    });

    on<SignUpStudentEvent>((event, emit) async {
      emit(AuthLoding());
      try {
        // تحقق إذا كان البريد موجودًا
        final existing = await supabase.from('student_table').select().eq('email', event.email).maybeSingle();
        if (existing != null) {
          emit(AuthError(message: "Email already exists"));
          return;
        }

        // hash كلمة المرور
        final hashedPassword = sha256.convert(utf8.encode(event.password)).toString();

        await supabase.from('student_table').insert({
          'name': event.name,
          'phone': event.phone,
          'email': event.email,
          'grade': event.grade,
          'age': event.age,
          'address': event.address,
          'condition': event.condition,
          'password': hashedPassword,
        });

        final userData = await supabase.from('student_table').select().eq('email', event.email).single();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', event.email);
        await prefs.setString('type', 'student');
        emit(Authanticated(type: 'student', userData: userData));
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    });
  }
}
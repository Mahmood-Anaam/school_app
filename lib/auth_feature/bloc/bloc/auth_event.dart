// lib/auth_feature/bloc/bloc/auth_event.dart
part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class ChecAuthanticated extends AuthEvent {}

class LoginEvent extends AuthEvent {
  LoginEvent({required this.email, required this.password});
  String email;
  String password;
}

class SignUpDriverEvent extends AuthEvent {
  final String name;
  final String phone;
  final String license;
  final String email;
  final String password;

  SignUpDriverEvent({
    required this.name,
    required this.phone,
    required this.license,
    required this.email,
    required this.password,
  });
}

class SignUpStudentEvent extends AuthEvent {
  final String name;
  final String phone;
  final String email;
  final String password;
  final String grade;
  final String age;
  final String address;
  final String condition;

  SignUpStudentEvent({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.grade,
    required this.age,
    required this.address,
    required this.condition,
  });
}

class LogoutEvent extends AuthEvent {}
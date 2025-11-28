// lib/auth_feature/bloc/bloc/auth_state.dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'auth_bloc.dart';

@immutable
sealed class AuthanticationState {}

class AuthInitial extends AuthanticationState {}

class AuthLoding extends AuthanticationState {}

class Authanticated extends AuthanticationState {
  final String type; // 'student' or 'driver'
  final Map<String, dynamic>? userData;

  Authanticated({required this.type, this.userData});
}

class Unauthanticated extends AuthanticationState {}

class AuthError extends AuthanticationState {
  String message;
  AuthError({required this.message});
}

class AuthLogout extends AuthanticationState {}
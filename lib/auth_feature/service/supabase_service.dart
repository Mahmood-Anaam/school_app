import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:school_app/config_service.dart';

class SupabaseService {
  static SupabaseClient? _client;

  SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        "Supabase not initialized. Call initialize() in main.dart",
      );
    }
    return _client!;
  }

  // Initialize one time only
  Future<void> initialize() async {
    if (_client != null) return;

    await Supabase.initialize(
      url: ConfigService.defaultSupabaseUrl,
      anonKey: ConfigService.defaultSupabaseAnonKey,
    );

    _client = Supabase.instance.client;
  }

  void subscribeSeats(Function(Map<String, dynamic>) onChange) {
    final client = _client!;

    client
        .channel('realtime:Seats')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'Seats',
          callback: (payload) {
            onChange(Map<String, dynamic>.from(payload.newRecord));
          },
        )
        .subscribe();
  }
}

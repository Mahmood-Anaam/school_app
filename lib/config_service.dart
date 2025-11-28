import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const String _liveStreamKey = 'live_stream_url';
  static const String _supabaseUrlKey = "https://kmdgdihhezpreizlusnz.supabase.co";
  static const String _supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttZGdkaWhoZXpwcmVpemx1c256Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQwNjQ3OTQsImV4cCI6MjA3OTY0MDc5NH0.NYOorcU33FyAxkpVHMTu0asN0bErBNTyADHSvmRLbkY";


  static const String defaultSupabaseUrl = "https://kmdgdihhezpreizlusnz.supabase.co";
  static const String defaultSupabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttZGdkaWhoZXpwcmVpemx1c256Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQwNjQ3OTQsImV4cCI6MjA3OTY0MDc5NH0.NYOorcU33FyAxkpVHMTu0asN0bErBNTyADHSvmRLbkY";

  static const String defaultLiveStreamUrl = 'https://example.com/default_live_stream';

  Future<void> saveLiveStreamUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_liveStreamKey, url.trim());
  }

  Future<String> getLiveStreamUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_liveStreamKey) ?? defaultLiveStreamUrl;
  }

  Future<void> saveSupabaseConfig(String url, String anonKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_supabaseUrlKey, url.trim());
    await prefs.setString(_supabaseAnonKey, anonKey.trim());
  }

  Future<Map<String, String>> getSupabaseConfig() async {
    final prefs = await SharedPreferences.getInstance();

    final url = prefs.getString(_supabaseUrlKey);
    final anonKey = prefs.getString(_supabaseAnonKey);

    return {
      'url': url?.trim().isNotEmpty == true ? url!.trim() : defaultSupabaseUrl,
      'anonKey': anonKey?.trim().isNotEmpty == true ? anonKey!.trim() : defaultSupabaseAnonKey,
    };
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> clearSupabaseConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_supabaseUrlKey);
    await prefs.remove(_supabaseAnonKey);
  }

  Future<bool> hasCustomSupabaseConfig() async {
    final config = await getSupabaseConfig();
    return config['url'] != defaultSupabaseUrl || config['anonKey'] != defaultSupabaseAnonKey;
  }
}
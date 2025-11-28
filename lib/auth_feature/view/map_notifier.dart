// lib/auth_feature/view/map_notifier.dart

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:school_app/auth_feature/service/supabase_service.dart';

class MapNotifier extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  RealtimeChannel? _busChannel;
  LatLng _busLocation = const LatLng(0, 0); // موقع افتراضي

  LatLng get busLocation => _busLocation;

  MapNotifier() {
    _initializeRealtime();
  }

  void _initializeRealtime() {
    // إغلاق القناة القديمة إذا كانت موجودة
    _busChannel?.unsubscribe();

    // إنشاء قناة جديدة للجدول 'Coordinates'
    _busChannel = _supabaseService.client.channel('bus_location_channel')
        .onPostgresChanges(
      event: PostgresChangeEvent.update, // نركز على تحديث البيانات
      schema: 'public',
      table: 'Coordinates',
      callback: (payload) {
        final newLocation = payload.newRecord;
        if (newLocation != null) {
          final double? lat = newLocation['latitude'] as double?;
          final double? lon = newLocation['longitude'] as double?;

          if (lat != null && lon != null) {
            _busLocation = LatLng(lat, lon);
            notifyListeners(); // إعلام المستمعين (الخريطة) بالتحديث
          }
        }
      },
    )
        .subscribe();

    // جلب الموقع الأولي عند التهيئة
    _fetchInitialLocation();
  }

  Future<void> _fetchInitialLocation() async {
    try {
      final response = await _supabaseService.client
          .from('Coordinates')
          .select('latitude, longitude')
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      final double? lat = response['latitude'] as double?;
      final double? lon = response['longitude'] as double?;

      if (lat != null && lon != null) {
        _busLocation = LatLng(lat, lon);
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching initial location: $e');
    }
  }

  @override
  void dispose() {
    _busChannel?.unsubscribe();
    super.dispose();
  }
}

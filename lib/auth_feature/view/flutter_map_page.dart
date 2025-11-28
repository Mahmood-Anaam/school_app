// lib/auth_feature/view/flutter_map_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart'; // مكتبة AnimatedMapController
import 'map_notifier.dart';

class FlutterMapPage extends StatefulWidget {
  const FlutterMapPage({super.key});

  @override
  State<FlutterMapPage> createState() => _FlutterMapPageState();
}

class _FlutterMapPageState extends State<FlutterMapPage>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimatedMapController _animatedMapController;

  LatLng? _lastBusLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _animatedMapController = AnimatedMapController(
      vsync: this,
      mapController: _mapController,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animatedMapController.dispose();
    super.dispose();
  }

  void _moveMap(LatLng newLocation, {double zoom = 15.0}) {
    _animatedMapController.animateTo(
      dest: newLocation,
      zoom: zoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    final busLocation = context.watch<MapNotifier>().busLocation;

    // تحريك الخريطة عند تغيير الموقع
    if (_lastBusLocation != busLocation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _moveMap(busLocation, zoom: 15.0);
      });
      _lastBusLocation = busLocation;
    }

    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: busLocation,
          initialZoom: 15.0,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.school_app.bus_tracker',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: busLocation,
                width: 80,
                height: 80,
                child: Image.asset('assets/icons/school_bus.png'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

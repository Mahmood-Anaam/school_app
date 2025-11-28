// lib/auth_feature/view/Home_Page.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:school_app/auth_feature/view/flutter_map_page.dart';
import 'package:school_app/auth_feature/view/setting_page.dart' as settings_page; // Alias for SettingPage
import 'package:school_app/auth_feature/view/student_tabs_page.dart';
import 'package:school_app/auth_feature/view/trip_schedule_page.dart';
import 'package:school_app/auth_feature/view/video_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const FlutterMapPage(), // <-- CORRECTED: Used class name directly
    const VideoPage(),
    const HistoryPage(),
    const TripSchedulePage(),
    const settings_page.SettingPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
      bottomNavigationBar: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: GNav(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            color: Theme.of(context).colorScheme.secondary,
            activeColor: Theme.of(context).colorScheme.secondary,
            tabBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
            gap: 8,
            padding: const EdgeInsets.all(10),
            onTabChange: (value) {
              _selectedIndex = value;
              setState(() {});
            },
            tabs: [
              GButton(
                text: 'map'.tr(),
                icon: Icons.location_on,
              ),
              GButton(
                text: 'live'.tr(),
                icon: Icons.airline_seat_recline_normal_outlined,
              ),
              GButton(
                text: 'history'.tr(),
                icon: Icons.history,
              ),
              GButton(
                text: 'trip_schedule'.tr(),
                icon: Icons.work_history,
              ),
              GButton(
                text: 'setting'.tr(),
                icon: Icons.settings,
              ),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
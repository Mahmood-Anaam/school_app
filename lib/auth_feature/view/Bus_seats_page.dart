// lib/auth_feature/view/Bus_seats_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_app/auth_feature/service/supabase_service.dart';
import 'package:easy_localization/easy_localization.dart';

class SvgBusSeatsPage extends StatefulWidget {
  const SvgBusSeatsPage({super.key});

  @override
  State<SvgBusSeatsPage> createState() => _SvgBusSeatsPageState();
}

class _SvgBusSeatsPageState extends State<SvgBusSeatsPage> {
  final int seatRows = 5; // 20 seats (5 rows × 4 seats)
  List<Map<String, dynamic>> seatsData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSeats();
    _subscribeRealtime();
  }

  Future<void> _fetchSeats() async {
    try {
      final client = SupabaseService().client;
      final res = await client
          .from('Seats')
          .select('id, seats_status')
          .order('id');

      seatsData = res;
    } catch (_) {}
    if (mounted) setState(() => isLoading = false);
  }

  void _subscribeRealtime() {
    SupabaseService().subscribeSeats((updatedSeat) {
      if (!mounted) return;

      final index = seatsData.indexWhere((s) => s['id'] == updatedSeat['id']);

      setState(() {
        if (index != -1) {
          seatsData[index] = updatedSeat;
        } else {
          seatsData.add(updatedSeat);
          seatsData.sort((a, b) => a['id'].compareTo(b['id']));
        }
      });
    });
  }

  bool seatStatus(int seatId) {
    final seat =
    seatsData.firstWhere((e) => e['id'] == seatId, orElse: () => {'seats_status': 0});
    return seat['seats_status'] == 1; // 1 = booked
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            )),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("bus_seats".tr()),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final seatSize = constraints.maxWidth * 0.15;
          final spacing = seatSize * 0.25;
          final aisle = seatSize * 0.8;

          return Center(
            child: Container(
              width: screenWidth < 400 ? screenWidth * 0.9 : 360,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/images/wheel.svg',
                    width: 70,
                    height: 70,
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView.separated(
                      itemCount: seatRows,
                      separatorBuilder: (_, __) => SizedBox(height: spacing),
                      itemBuilder: (context, row) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _seatWidget(row, 0, seatSize),
                            SizedBox(width: spacing),
                            _seatWidget(row, 1, seatSize),
                            SizedBox(width: aisle),
                            _seatWidget(row, 2, seatSize),
                            SizedBox(width: spacing),
                            _seatWidget(row, 3, seatSize),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legendItem(Colors.green, "seat_available".tr()),
                      const SizedBox(width: 20),
                      _legendItem(Colors.red, "seat_booked".tr()),
                    ],
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _seatWidget(int row, int col, double size) {
    final seatId = row * 4 + col + 1;
    final booked = seatStatus(seatId);

    return Column(
      children: [
        SvgPicture.asset(
          'assets/images/seat_1.svg',
          width: size,
          height: size,
          colorFilter:
          ColorFilter.mode(booked ? Colors.red : Colors.green, BlendMode.srcIn),
        ),

        const SizedBox(height: 4),

        Text(
          "$seatId",
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,  // نص أسود كما طلبت
          ),
        ),
      ],
    );
  }
}

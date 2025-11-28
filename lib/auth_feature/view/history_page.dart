// lib/auth_feature/view/history_page.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final historyItems = [
      {
        "date": "2025-10-10",
        "pickup": "07:30 AM",
        "drop": "02:15 PM",
        "status": "On Time",
      },
      {
        "date": "2025-10-09",
        "pickup": "07:40 AM",
        "drop": "02:20 PM",
        "status": "Late",
      },
      {
        "date": "2025-10-08",
        "pickup": "07:28 AM",
        "drop": "02:10 PM",
        "status": "On Time",
      },
      {"date": "2025-10-07", "pickup": "—", "drop": "—", "status": "Absent"},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "bus_history".tr(), // الترجمات هنا
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: historyItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = historyItems[index];
            final statusColor = item["status"] == "On Time"
                ? Colors.greenAccent
                : item["status"] == "Late"
                ? Colors.orangeAccent
                : Colors.redAccent;

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 1.5),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                leading: CircleAvatar(
                  backgroundColor: statusColor,
                  radius: 20,
                  child: const Icon(Icons.directions_bus, color: Colors.white),
                ),
                title: Text(
                  "${"date".tr()}: ${item["date"]}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${"pickup".tr()}: ${item["pickup"]}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "${"drop".tr()}: ${item["drop"]}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                trailing: Text(
                  item["status"] == "On Time"
                      ? "on_time".tr()
                      : item["status"] == "Late"
                      ? "late".tr()
                      : "absent".tr(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
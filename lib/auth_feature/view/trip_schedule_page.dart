// lib/auth_feature/view/trip_schedule_page.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // استيراد الحزمة

class TripSchedulePage extends StatelessWidget {
  const TripSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    // بيانات افتراضية
    String driverName = "سالم العتيبي";
    String busNumber = "الحافلة رقم 12";
    String startTime = "06:30 صباحًا";
    String arrivalSchoolTime = "07:10 صباحًا";
    String returnTime = "02:15 مساءً";
    String homeArrivalTime = "03:00 مساءً";
    String tripStatus = "جارية"; // القيم الممكنة: جارية - مكتملة - مؤجلة

    Color statusColor;
    if (tripStatus == "جارية") {
      statusColor = Colors.green;
    } else if (tripStatus == "مكتملة") {
      statusColor = Colors.blue;
    } else {
      statusColor = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'trip_schedule_title'
              .tr(), // ترجمة عنوان الصفحة "جدول الرحلات اليومية"
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          double baseFont = screenWidth < 400 ? 14 : 18;
          double titleFont = screenWidth < 400 ? 18 : 22;

          return Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 4,
                color: Theme.of(context).colorScheme.surface,
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.03,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.directions_bus_filled,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        size: 60,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'trip_schedule_title'
                            .tr(), // ترجمة "مواعيد الرحلات اليومية"
                        style: TextStyle(
                          fontSize: titleFont,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const Divider(thickness: 1, height: 30),
                      Text(
                        "${'driver_label'.tr()}$driverName", // ترجمة "السائق"
                        style: TextStyle(fontSize: baseFont),
                      ),
                      Text(
                        "${'bus_number_label'.tr()}$busNumber", // ترجمة "رقم الحافلة"
                        style: TextStyle(fontSize: baseFont),
                      ),
                      const SizedBox(height: 10),
                      const Divider(thickness: 1),
                      Text(
                        'departure_schedule_label'
                            .tr(), // ترجمة "مواعيد التحرك والانطلاق"
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: baseFont,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${'departure_from_home'.tr()}: $startTime", // ترجمة "الانطلاق من المنازل"
                        style: TextStyle(fontSize: baseFont),
                      ),
                      Text(
                        "${'arrival_at_school'.tr()}: $arrivalSchoolTime", // ترجمة "الوصول إلى المدرسة"
                        style: TextStyle(fontSize: baseFont),
                      ),
                      const SizedBox(height: 10),
                      const Divider(thickness: 1),
                      Text(
                        'return_schedule_label'.tr(), // ترجمة "مواعيد العودة"
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: baseFont,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${'departure_from_school'.tr()}: $returnTime", // ترجمة "التحرك من المدرسة"
                        style: TextStyle(fontSize: baseFont),
                      ),
                      Text(
                        "${'arrival_at_home'.tr()}: $homeArrivalTime", // ترجمة "الوصول إلى المنازل"
                        style: TextStyle(fontSize: baseFont),
                      ),
                      const SizedBox(height: 15),
                      const Divider(thickness: 1),
                      Text(
                        'trip_status_label'.tr(), // ترجمة "حالة الرحلة الحالية"
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: baseFont,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor, width: 2),
                        ),
                        child: Text(
                          tripStatus,
                          style: TextStyle(
                            fontSize: baseFont + 2,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
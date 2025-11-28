// lib/auth_feature/view/student_detail_page.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // استيراد الحزمة

class StudentDetailPage extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentDetailPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          student["name"] ?? '',
          style: const TextStyle(
            color: Color(0xffD7FD8C),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xffD7FD8C)),
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xffD7FD8C), width: 2),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: ListView(
              children: [
                // صورة الطالب
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xffD7FD8C),
                  backgroundImage: const AssetImage(
                    'assets/images/student_avatar.png',
                  ),
                  child: student["image"] == null
                      ? const Icon(
                    Icons.person,
                    size: 60,
                    color: Color(0xff135FCB),
                  )
                      : null,
                ),
                const SizedBox(height: 18),

                Center(
                  child: Text(
                    "student_info".tr(), // ترجمة النص
                    style: const TextStyle(
                      color: Color(0xffD7FD8C),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // عناصر المعلومات مع Divider
                infoRow("name_label".tr(), student["name"] ?? ''),
                const Divider(color: Color(0xffD7FD8C), thickness: 1),
                infoRow("grade_label".tr(), student["grade"] ?? ''),
                const Divider(color: Color(0xffD7FD8C), thickness: 1),
                infoRow("age_label".tr(), student["age"] ?? ''),
                const Divider(color: Color(0xffD7FD8C), thickness: 1),
                infoRow("address_label".tr(), student["address"] ?? ''),
                const Divider(color: Color(0xffD7FD8C), thickness: 1),
                infoRow("condition_label".tr(), student["condition"] ?? ''),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xffD7FD8C),
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
        ],
      ),
    );
  }
}
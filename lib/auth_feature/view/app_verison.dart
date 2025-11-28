import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AppVersionPage extends StatelessWidget {
  const AppVersionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_version'.tr()), // استخدام الترجمة من JSON
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: const IconThemeData(color: Color(0xffD7FD8C)),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "1.0.0", // الإصدار ثابت
          style: const TextStyle(
            color: Color(0xffD7FD8C),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

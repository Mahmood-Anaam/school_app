import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('help_support'.tr()), // استخدام الترجمة من JSON
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: const IconThemeData(color: Color(0xffD7FD8C)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'contact_details'.tr(), // استخدم المفتاح الموجود في JSON
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}

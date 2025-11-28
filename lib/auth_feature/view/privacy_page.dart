import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('privacy_policy'.tr()),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: const IconThemeData(color: Color(0xffD7FD8C)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(
          'privacy_content'.tr(),
          textAlign: TextAlign.right,
          style: const TextStyle(color: Colors.white70, height: 1.6, fontSize: 15),
        ),
      ),
    );
  }
}
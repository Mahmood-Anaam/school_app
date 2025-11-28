import 'package:flutter/material.dart';
import 'package:school_app/auth_feature/view/driver_signup.dart';
import 'package:school_app/auth_feature/view/signup_Page.dart';
import 'package:easy_localization/easy_localization.dart'; // استيراد الحزمة

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ترجمة النص "Welcome to"
            Text(
              'welcome_to'.tr(), // استخدام tr() للترجمة
              style: TextStyle(fontSize: 22, color: Theme.of(context).textTheme.bodyLarge!.color),
            ),
            const SizedBox(height: 5),
            // ترجمة النص "Hafelati+"
            Text(
              'hafelati_plus'.tr(), // استخدام tr() للترجمة
              style: TextStyle(fontSize: 22, color: Theme.of(context).textTheme.bodyLarge!.color),
            ),
            SizedBox(
              width: 150,
              height: 150,
              child: Center(
                child: Image.asset("assets/images/driver.png", scale: 0.1),
              ),
            ),
            // زر مدرسة
            SizedBox(
              width: 100,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BusDriverSignUpPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).textTheme.bodyLarge!.color!, width: 2),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).textTheme.bodyLarge!.color,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Driver_button'.tr(), // ترجمة النص "School"
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 150,
              height: 150,
              child: Center(
                child: Image.asset("assets/images/student.png", scale: 0.1),
              ),
            ),
            // زر طالب
            SizedBox(
              width: 100,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ParentSignUpPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).textTheme.bodyLarge!.color!, width: 2),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).textTheme.bodyLarge!.color,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'student_button'.tr(), // ترجمة النص "Student"
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
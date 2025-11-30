import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:school_app/auth_feature/service/supabase_auth.dart';
import 'reset_password_page.dart';

/// Screen to enter the verification OTP sent to the user's email.
/// - Shows instructions and clear messages (success/failure)
/// - Allows resending OTP with a countdown timer
/// - On successful verification navigates to `ResetPasswordPage`
class VerificationOtpPage extends StatefulWidget {
  final String email;
  const VerificationOtpPage({super.key, required this.email});

  @override
  State<VerificationOtpPage> createState() => _VerificationOtpPageState();
}

class _VerificationOtpPageState extends State<VerificationOtpPage> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _processing = false;

  // Resend cooldown in seconds
  static const int _initialCooldown = 60;
  int _remaining = _initialCooldown;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _remaining = _initialCooldown;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_remaining > 0) {
          _remaining -= 1;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;
    try {
      await SupabaseAuth().sendOtp(widget.email);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('otp_sent'.tr())));
      _startCooldown();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _processing = true);
    try {
      await SupabaseAuth().verifyOtp(_otpController.text.trim(), widget.email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('otp_verified'.tr()),
          backgroundColor: Colors.green,
        ),
      );

      if (!mounted) return;
      // Navigate to reset-password screen after successful verification
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordPage(email: widget.email),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff377FCC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'enter_otp'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.confirmation_number,
                      size: 64,
                      color: Color(0xff377FCC),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'enter_otp_instruction'.tr(args: [widget.email]),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _otpController,
                      decoration: InputDecoration(
                        labelText: 'otp_label'.tr(),
                        prefixIcon: const Icon(Icons.pin),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.trim().length != 6
                          ? 'invalid_otp_error'.tr()
                          : null,
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _processing ? null : _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff377FCC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _processing
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'verify_otp'.tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'didnt_receive_otp'.tr(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: _canResend ? _resendOtp : null,
                          child: Text(
                            _canResend
                                ? 'resend_otp'.tr()
                                : 'resend_in'.tr(args: ['$_remaining']),
                          ),
                        ),
                      ],
                    ),

                    // show remaining seconds when cannot resend
                    if (!_canResend) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'resend_in'.tr(args: ['$_remaining']),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),
                    // helpful note
                    Text(
                      'otp_help_note'.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

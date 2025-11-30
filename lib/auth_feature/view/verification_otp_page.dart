import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_app/auth_feature/service/supabase_auth.dart';
import 'reset_password_page.dart';
import 'dart:ui' as ui;

class VerificationOtpPage extends StatefulWidget {
  final String email;
  const VerificationOtpPage({super.key, required this.email});

  @override
  State<VerificationOtpPage> createState() => _VerificationOtpPageState();
}

class _VerificationOtpPageState extends State<VerificationOtpPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _processing = false;
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
    _controller.dispose();
    _focusNode.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('otp_sent'.tr()),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      _startCooldown();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(e.toString())),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _controller.text.trim();
    if (otp.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 12),
              Text('invalid_otp_error'.tr()),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _processing = true);
    try {
      await SupabaseAuth().verifyOtp(otp, widget.email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('otp_verified'.tr()),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordPage(email: widget.email),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(e.toString())),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xff377FCC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isRTL ? Icons.arrow_forward : Icons.arrow_back,
            color: const Color(0xffD7FD8C),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xff135FCB),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xffD7FD8C),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xffD7FD8C).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    size: 60,
                    color: Color(0xffD7FD8C),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  'enter_otp'.tr(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffD7FD8C),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'enter_otp_instruction'.tr() + widget.email,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Single OTP Input Field
                Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: TextFormField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xff135FCB),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xffD7FD8C),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xffD7FD8C),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: '•••• ••••',
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _processing ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff135FCB),
                      foregroundColor: const Color(0xffD7FD8C),
                      disabledBackgroundColor: const Color(
                        0xff135FCB,
                      ).withOpacity(0.6),
                      elevation: 8,
                      shadowColor: const Color(0xffD7FD8C).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xffD7FD8C),
                          width: 2,
                        ),
                      ),
                    ),
                    child: _processing
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xffD7FD8C),
                              ),
                            ),
                          )
                        : Text(
                            'verify_otp'.tr(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Resend OTP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  textDirection: isRTL
                      ? ui.TextDirection.rtl
                      : ui.TextDirection.ltr,
                  children: [
                    Text(
                      'didnt_receive_otp'.tr(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                      ),
                      textDirection: isRTL
                          ? ui.TextDirection.rtl
                          : ui.TextDirection.ltr,
                    ),
                    const SizedBox(width: 3),
                    TextButton(
                      onPressed: _canResend ? _resendOtp : null,
                      child: Text(
                        _canResend
                            ? 'resend_otp'.tr()
                            : '${'resend_in'.tr()} $_remaining ${isRTL ? 'ثانية' : 'second'}',
                        style: TextStyle(
                          color: _canResend
                              ? const Color(0xffD7FD8C)
                              : Colors.white.withOpacity(0.5),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: isRTL
                            ? ui.TextDirection.rtl
                            : ui.TextDirection.ltr,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Help Note
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'otp_help_note'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.5,
                    ),
                    textDirection: isRTL
                        ? ui.TextDirection.rtl
                        : ui.TextDirection.ltr,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

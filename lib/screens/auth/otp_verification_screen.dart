import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../main_nav_screen.dart';
import 'customer_register_dialog.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final bool isDevMode;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    this.isDevMode = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isVerifying = false;
  String? _errorMessage;
  int _secondsRemaining = 30;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();

    // If in development mode, pre-fill dev OTP for rapid testing convenience
    if (widget.isDevMode) {
      _otpController.text = AuthService().devOtpCode;
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _secondsRemaining = 30;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleResend() async {
    setState(() {
      _errorMessage = null;
    });
    final res = await AuthService().sendOtp(widget.phone);
    if (!mounted) return;
    if (res['success'] == true) {
      _startCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryMintDark,
          content: Text(res['message'] as String),
        ),
      );
    } else {
      setState(() {
        _errorMessage = res['message'] as String;
      });
    }
  }

  Future<void> _handleVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit code';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final res = await AuthService().verifyOtp(
      phone: widget.phone,
      otp: otp,
    );

    if (!mounted) return;

    setState(() {
      _isVerifying = false;
    });

    if (res['success'] == true) {
      final isNewUser = res['isNewUser'] == true;

      if (isNewUser) {
        // First-time customer: prompt for Full Name & Address
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => CustomerRegisterDialog(
            onCompleted: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainNavScreen()),
                (route) => false,
              );
            },
          ),
        );
      } else {
        // Returning customer: proceed directly to main app
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavScreen()),
          (route) => false,
        );
      }
    } else {
      setState(() {
        _errorMessage = res['message'] as String? ?? 'Invalid verification code';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedPhone = AuthService.formatIndianPhone(widget.phone);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.charcoal, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Verification Code',
          style: TextStyle(
            color: AppColors.charcoal,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Icon
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryMintLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_read_rounded,
                      color: AppColors.primaryMintDark,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'Verify Mobile Number',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Center(
                  child: Text(
                    'We sent a 6-digit verification code to\n$formattedPhone',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Development Mode Notice (Testing helper)
                if (widget.isDevMode)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: Color(0xFFB45309), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Development Testing Mode: Enter test OTP "${AuthService().devOtpCode}" to verify without SMS gateway costs.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF92400E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enter 6-Digit Code',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // OTP Input Field
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 10,
                            color: AppColors.charcoal,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '••••••',
                            hintStyle: const TextStyle(
                              letterSpacing: 6,
                              color: AppColors.textMuted,
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceMuted,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                          ),
                          onSubmitted: (_) => _handleVerify(),
                        ),

                        // Error Banner
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  size: 16, color: AppColors.statusCancelled),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: AppColors.statusCancelled,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Verify Button
                        CustomButton(
                          text: 'Verify & Sign In',
                          icon: Icons.check_rounded,
                          isLoading: _isVerifying,
                          onPressed: _isVerifying ? null : _handleVerify,
                        ),

                        const SizedBox(height: 16),

                        // Resend Section
                        Center(
                          child: _secondsRemaining > 0
                              ? Text(
                                  'Resend code in ${_secondsRemaining}s',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : TextButton.icon(
                                  onPressed: _handleResend,
                                  icon: const Icon(Icons.refresh_rounded,
                                      size: 16),
                                  label: const Text(
                                    'Resend Code',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryMintDark,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
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

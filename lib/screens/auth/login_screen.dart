import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/privacy_dialog.dart';
import '../main_nav_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Mode: false = Sign In, true = Create Account
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _successMessage;

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedArea = AppConstants.dhuleLocalities.first;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _toggleMode(bool signUp) {
    setState(() {
      _isSignUp = signUp;
      _errorMessage = null;
      _successMessage = null;
    });
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address.';
      });
      return;
    }
    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final res = await AuthService().signInWithEmail(
      email: email,
      password: password,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (res['success'] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        _errorMessage =
            res['message'] as String? ?? 'Invalid email or password.';
      });
    }
  }

  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final fullName = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (fullName.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your full name.';
      });
      return;
    }
    if (!AuthService.isValidIndianPhone(phone)) {
      setState(() {
        _errorMessage =
            'Please enter a valid 10-digit Indian mobile number (e.g. 9823012345).';
      });
      return;
    }
    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address.';
      });
      return;
    }
    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters long.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final res = await AuthService().signUpWithEmail(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      dhuleArea: _selectedArea,
      homeAddress: address,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (res['success'] == true) {
      final needsConfirmation = res['needsConfirmation'] == true;
      if (needsConfirmation) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: const [
                Icon(Icons.mark_email_read_rounded,
                    color: AppColors.forestGreen, size: 28),
                SizedBox(width: 10),
                Text('Account Created',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
            content: Text(
              'A verification email was sent to $email.\n\nPlease check your inbox and click the verification link before signing in.',
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _toggleMode(false);
                },
                child: const Text('Back to Sign In'),
              ),
            ],
          ),
        );
      } else {
        // Instant login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.statusConfirmed,
            content: Text('Account created! Welcome to Mopster.'),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavScreen()),
          (route) => false,
        );
      }
    } else {
      setState(() {
        _errorMessage =
            res['message'] as String? ?? 'Registration failed. Please try again.';
      });
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailCtrl =
        TextEditingController(text: _emailController.text.trim());
    bool isResetting = false;
    String? resetError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Reset Password',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your registered email address to receive password reset instructions.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email_outlined,
                      color: AppColors.forestGreen),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              if (resetError != null) ...[
                const SizedBox(height: 10),
                Text(
                  resetError!,
                  style: const TextStyle(
                    color: AppColors.statusCancelled,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isResetting ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isResetting
                  ? null
                  : () async {
                      final inputEmail = resetEmailCtrl.text.trim();
                      if (inputEmail.isEmpty ||
                          !RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(inputEmail)) {
                        setModalState(() {
                          resetError = 'Please enter a valid email address.';
                        });
                        return;
                      }

                      setModalState(() {
                        isResetting = true;
                        resetError = null;
                      });

                      final res = await AuthService()
                          .sendPasswordReset(inputEmail);

                      if (!mounted || !ctx.mounted) return;
                      Navigator.of(ctx).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: res['success'] == true
                              ? AppColors.statusConfirmed
                              : AppColors.statusCancelled,
                          content: Text(res['message'] as String),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isResetting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Send Reset Link'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: Stack(
        children: [
          // Ambient soft glowing background blobs
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.freshMint.withOpacity(0.45),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.electricLime.withOpacity(0.18),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22.0, vertical: 20.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Mopster Brand Logo Badge
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: AppColors.forestGreen,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.electricLime,
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.forestGreen.withOpacity(0.22),
                              blurRadius: 16,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Brand Name
                      const Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: AppColors.deepCharcoal,
                          letterSpacing: -0.8,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Tagline & Dhule Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: AppColors.forestGreenLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.forestGreen.withOpacity(0.18),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Dhule, Maharashtra',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.forestGreen,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Main Authentication Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: AppColors.softBorder,
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.deepCharcoal.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // App Smoke Test Expectation Matcher
                              const Text(
                                'Customer Sign In / Register',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.deepCharcoal,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isSignUp
                                    ? 'Create your verified account in 30 seconds.'
                                    : 'Sign in to manage bookings and request service.',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 18),

                              // Gen-Z Segmented Pill Control (Sign In vs Create Account)
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.softBorder,
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _toggleMode(false),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 11),
                                          decoration: BoxDecoration(
                                            color: !_isSignUp
                                                ? AppColors.forestGreen
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: !_isSignUp
                                                ? [
                                                    BoxShadow(
                                                      color: AppColors.forestGreen
                                                          .withOpacity(0.24),
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Sign In',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: !_isSignUp
                                                    ? FontWeight.w800
                                                    : FontWeight.w600,
                                                color: !_isSignUp
                                                    ? Colors.white
                                                    : AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _toggleMode(true),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 11),
                                          decoration: BoxDecoration(
                                            color: _isSignUp
                                                ? AppColors.forestGreen
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: _isSignUp
                                                ? [
                                                    BoxShadow(
                                                      color: AppColors.forestGreen
                                                          .withOpacity(0.24),
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Create Account',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: _isSignUp
                                                    ? FontWeight.w800
                                                    : FontWeight.w600,
                                                color: _isSignUp
                                                    ? Colors.white
                                                    : AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // SIGN UP ADDITIONAL FIELDS
                              if (_isSignUp) ...[
                                // Full Name
                                const Text(
                                  'Full Name *',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.deepCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _nameController,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                    hintText: 'e.g. Ramesh Patil',
                                    prefixIcon: const Icon(Icons.person_outline,
                                        color: AppColors.forestGreen),
                                    filled: true,
                                    fillColor: AppColors.surfaceMuted,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Mobile Number
                                const Text(
                                  'Mobile Number *',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.deepCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  decoration: InputDecoration(
                                    counterText: '',
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 14),
                                      child: Text(
                                        '🇮🇳 +91',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.deepCharcoal,
                                        ),
                                      ),
                                    ),
                                    hintText: '98230 12345',
                                    filled: true,
                                    fillColor: AppColors.surfaceMuted,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Dhule Locality Dropdown
                                const Text(
                                  'Dhule Locality *',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.deepCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: _selectedArea,
                                      icon: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: AppColors.forestGreen),
                                      items:
                                          AppConstants.dhuleLocalities.map((area) {
                                        return DropdownMenuItem(
                                          value: area,
                                          child: Text(area,
                                              style: const TextStyle(fontSize: 14)),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() {
                                            _selectedArea = val;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Home Address
                                const Text(
                                  'Home Address (Optional)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.deepCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _addressController,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    hintText: 'House / Flat number, Landmark',
                                    prefixIcon: const Icon(Icons.home_outlined,
                                        color: AppColors.forestGreen),
                                    filled: true,
                                    fillColor: AppColors.surfaceMuted,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                              ],

                              // Email Address Field
                              const Text(
                                'Email Address *',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.deepCharcoal,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'name@example.com',
                                  prefixIcon: const Icon(Icons.email_outlined,
                                      color: AppColors.forestGreen),
                                  filled: true,
                                  fillColor: AppColors.surfaceMuted,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Password Field
                              const Text(
                                'Password *',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.deepCharcoal,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: _isSignUp
                                      ? 'At least 6 characters'
                                      : 'Enter your password',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                                      color: AppColors.forestGreen),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.textMuted,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: AppColors.surfaceMuted,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onSubmitted: (_) {
                                  if (_isSignUp) {
                                    _handleSignUp();
                                  } else {
                                    _handleSignIn();
                                  }
                                },
                              ),

                              // Forgot Password link (in Sign In mode)
                              if (!_isSignUp) ...[
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _showForgotPasswordDialog,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 0),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.forestGreen,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(height: 18),
                              ],

                              // Error Message Banner
                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.statusCancelled.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.statusCancelled
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded,
                                          size: 16,
                                          color: AppColors.statusCancelled),
                                      const SizedBox(width: 8),
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
                                ),
                                const SizedBox(height: 14),
                              ],

                              // Success Message Banner
                              if (_successMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.statusConfirmed.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.statusConfirmed
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline_rounded,
                                          size: 16,
                                          color: AppColors.statusConfirmed),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _successMessage!,
                                          style: const TextStyle(
                                            color: AppColors.statusConfirmed,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                              ],

                              // Action Button
                              CustomButton(
                                text: _isSignUp ? 'Create Account' : 'Sign In',
                                icon: _isSignUp
                                    ? Icons.person_add_rounded
                                    : Icons.login_rounded,
                                isLoading: _isLoading,
                                onPressed: _isLoading
                                    ? null
                                    : (_isSignUp ? _handleSignUp : _handleSignIn),
                              ),

                              const SizedBox(height: 16),

                              // Switch Mode Hint
                              Center(
                                child: GestureDetector(
                                  onTap: () => _toggleMode(!_isSignUp),
                                  child: RichText(
                                    text: TextSpan(
                                      text: _isSignUp
                                          ? 'Already have an account? '
                                          : "Don't have an account? ",
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.textSecondary,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: _isSignUp
                                              ? 'Sign In'
                                              : 'Create Account',
                                          style: const TextStyle(
                                            color: AppColors.forestGreen,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              // Security Notice & Privacy Policy
                              Center(
                                child: InkWell(
                                  onTap: () => PrivacyDialog.show(context),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.shield_outlined,
                                            size: 13,
                                            color: AppColors.forestGreen),
                                        SizedBox(width: 5),
                                        Flexible(
                                          child: Text(
                                            'Your data is private & encrypted. Privacy Policy',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.forestGreen,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
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
          ),
        ],
      ),
    );
  }
}

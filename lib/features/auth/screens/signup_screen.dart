import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cyan_button.dart';
import '../../../core/widgets/ev_input_field.dart';
import '../../../core/widgets/ev_logo.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordObscured = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all required fields.',
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password must be at least 6 characters.',
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = AuthService();
      if (auth.isReady) {
        final res = await auth.signUp(
          email: email,
          password: password,
          name: name,
          phone: phone,
        );

        if (mounted) {
          if (res.session == null && res.user != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Account created! Please check your email to confirm registration.',
                  style: GoogleFonts.outfit(color: Colors.white),
                ),
                backgroundColor: const Color(0xFF00C853),
                duration: const Duration(seconds: 5),
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
            return;
          }
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const DashboardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message,
              style: GoogleFonts.outfit(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sign-up failed: $e',
              style: GoogleFonts.outfit(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFF030812),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(isDesktop ? 16 : 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isDesktop ? 20 : 0),
            border: isDesktop
                ? Border.all(
                    color: const Color(0xFF007299).withValues(alpha: 0.6),
                    width: 1.5,
                  )
                : null,
            boxShadow: isDesktop
                ? [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                      blurRadius: 28,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isDesktop ? 18 : 0),
            child: Stack(
              children: [
                // 1. Full-screen Cinematic EV Charging Background
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/ev_charging_cinematic.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.centerLeft,
                  ),
                ),

                // 2. Seamless Gradient Vignette Mask
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.12),
                          Colors.transparent,
                          const Color(0xFF003050).withValues(alpha: 0.12),
                          const Color(0xFF020C1C).withValues(alpha: 0.25),
                        ],
                        stops: const [0.0, 0.35, 0.70, 1.0],
                      ),
                    ),
                  ),
                ),

                // Ambient luminous neon glow behind the right glass card
                Positioned(
                  right: 30,
                  top: 60,
                  bottom: 60,
                  width: 580,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        gradient: RadialGradient(
                          center: const Alignment(0.1, -0.1),
                          radius: 0.85,
                          colors: [
                            const Color(0xFF00E5FF).withValues(alpha: 0.16),
                            const Color(0xFF0077B6).withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Foreground Layout
                SafeArea(
                  child: isDesktop
                      ? _buildDesktopLayout()
                      : _buildMobileLayout(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Brand Header
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.only(left: 54, top: 48, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                EvLogo(fontSize: 32, iconHeight: 74, showTagline: true),
                Spacer(),
              ],
            ),
          ),
        ),

        // Right Column: Signup Card
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(right: 64),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: SizedBox(width: 490, child: _buildSignupCard()),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const EvLogo(
              fontSize: 22,
              iconHeight: 40,
              showTagline: true,
              isHorizontal: true,
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _buildSignupCard(isCompact: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupCard({bool isCompact = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isCompact ? 24 : 34),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.70),
            const Color(0xFF00E5FF).withValues(alpha: 0.55),
            const Color(0xFF004D73).withValues(alpha: 0.25),
            const Color(0xFF00E5FF).withValues(alpha: 0.40),
          ],
          stops: const [0.0, 0.30, 0.70, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: isCompact ? 28 : 45,
            offset: Offset(0, isCompact ? 12 : 22),
            spreadRadius: isCompact ? 1 : 2,
          ),
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.28),
            blurRadius: isCompact ? 22 : 34,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.all(isCompact ? 1.4 : 1.8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isCompact ? 22.6 : 32.2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 20 : 42,
              vertical: isCompact ? 16 : 42,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.14),
                  const Color(0xFF0A223E).withValues(alpha: 0.22),
                  const Color(0xFF030D1C).withValues(alpha: 0.36),
                ],
                stops: const [0.0, 0.35, 1.0],
              ),
              borderRadius: BorderRadius.circular(isCompact ? 22.6 : 32.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Create Your Account',
                  style: GoogleFonts.outfit(
                    fontSize: isCompact ? 21 : 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isCompact ? 2 : 6),
                Text(
                  'Join the EV revolution. Charge, Control, Drive.',
                  style: GoogleFonts.outfit(
                    fontSize: isCompact ? 12 : 13.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8FA7C4),
                  ),
                ),
                SizedBox(height: isCompact ? 14 : 24),

                // Full Name
                EvInputField(
                  controller: _nameController,
                  hintText: 'Full Name',
                  prefixIcon: Icons.person_outline_rounded,
                ),
                SizedBox(height: isCompact ? 8 : 14),

                // Email Address
                EvInputField(
                  controller: _emailController,
                  hintText: 'Email Address',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: isCompact ? 8 : 14),

                // Phone Number
                EvInputField(
                  controller: _phoneController,
                  hintText: 'Phone Number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: isCompact ? 8 : 14),

                // Password
                EvInputField(
                  controller: _passwordController,
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  isObscured: _isPasswordObscured,
                  onToggleObscure: () {
                    setState(() => _isPasswordObscured = !_isPasswordObscured);
                  },
                ),
                SizedBox(height: isCompact ? 14 : 26),

                // SIGN UP Button
                CyanButton(
                  text: 'SIGN UP',
                  height: isCompact ? 42 : 48,
                  isLoading: _isLoading,
                  onPressed: _handleSignup,
                ),
                SizedBox(height: isCompact ? 12 : 20),

                // Already have an account? Login
                Center(
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: GoogleFonts.outfit(
                            fontSize: isCompact ? 12.5 : 13.5,
                            color: const Color(0xFF8FA7C4),
                          ),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: GoogleFonts.outfit(
                                fontSize: isCompact ? 12.5 : 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.cyan,
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
          ),
        ),
      ),
    );
  }
}

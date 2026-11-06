import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/widgets/ev_input_field.dart';
import '../../../core/widgets/ev_logo.dart';
import 'signup_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordObscured = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter both email and password.',
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
        await auth.signIn(email: email, password: password);
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
              'Authentication failed: $e',
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
          // Outer framed container with cyan border matching Image 2
          margin: EdgeInsets.all(isDesktop ? 16 : 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isDesktop ? 22 : 0),
            border: isDesktop
                ? Border.all(
                    color: const Color(0xFF007299).withValues(alpha: 0.65),
                    width: 1.8,
                  )
                : null,
            boxShadow: isDesktop
                ? [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.18),
                      blurRadius: 36,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isDesktop ? 20 : 0),
            child: Stack(
              children: [
                // 1. Full-screen Cinematic Scenery
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/ev_charging_cinematic.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.centerLeft,
                  ),
                ),

                // 2. Subtle Vignette Overlay that preserves the background lights
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
                            const Color(0xFF00E5FF).withValues(alpha: 0.35),
                            const Color(0xFF0096C7).withValues(alpha: 0.15),
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
        // Left Column: Brand Header at top
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.only(left: 48, top: 40, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                EvLogo(iconHeight: 76, showTagline: true),
                Spacer(),
              ],
            ),
          ),
        ),

        // Right Column: Floating Large Glassmorphism Login Card
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(right: 56),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: SizedBox(
                  width: 520, // Substantially larger and proportional matching Image 2
                  child: _buildLoginCard(),
                ),
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
            const EvLogo(iconHeight: 46, showTagline: true),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _buildLoginCard(isCompact: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard({bool isCompact = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isCompact ? 26 : 34),
        // 3D Metallic Cyan Chrome Bevel Rim
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF), // Specular chrome flash
            Color(0xFFC4FAFC), // Ice cyan gleam
            Color(0xFF00E5FF), // Pure metallic cyan
            Color(0xFF005E73), // Titanium shadow groove
            Color(0xFF76FDFF), // Reflected cyan highlight
            Color(0xFFFFFFFF), // Specular bottom-right corner reflection
          ],
          stops: [0.0, 0.18, 0.42, 0.65, 0.88, 1.0],
        ),
        boxShadow: [
          // Deep 3D drop shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: isCompact ? 30 : 45,
            offset: Offset(0, isCompact ? 14 : 22),
            spreadRadius: isCompact ? 1 : 2,
          ),
          // Intense Metallic Cyan neon luminous halo
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.45),
            blurRadius: isCompact ? 28 : 42,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.all(isCompact ? 1.4 : 1.8), // 3D bevel edge thickness
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isCompact ? 24.6 : 32.2),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 22 : 46,
            vertical: isCompact ? 20 : 48,
          ),
          decoration: BoxDecoration(
            // Metallic Cyan Chrome with brushed specular reflections and horizon sheen
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0D2F42), // Deep metallic cyan highlight
                Color(0xFF082230), // Brushed electric teal
                Color(0xFF031622), // Solid deep cyber alloy
                Color(0xFF0A293B), // Metallic bounce reflection
                Color(0xFF021019), // Deep solid obsidian-titanium base
              ],
              stops: [0.0, 0.25, 0.55, 0.80, 1.0],
            ),
            borderRadius: BorderRadius.circular(isCompact ? 24.6 : 32.2),
            border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.60),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title: Welcome Back
              Text(
                'Welcome Back',
                style: GoogleFonts.outfit(
                  fontSize: isCompact ? 24 : 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.65),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              SizedBox(height: isCompact ? 4 : 8),

              // Subtitle
              Text(
                'Sign in to your EV-MASTER account',
                style: GoogleFonts.outfit(
                  fontSize: isCompact ? 12.5 : 14.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFCCFBF1), // Bright luminous ice cyan
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.60),
                      offset: const Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
              SizedBox(height: isCompact ? 18 : 34),

              // Email Address Field
              EvInputField(
                controller: _emailController,
                hintText: 'Email Address',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: isCompact ? 12 : 20),

              // Password Field
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
              SizedBox(height: isCompact ? 18 : 32),

              // LOGIN Button (High-Contrast Obsidian Cyber Button)
              Container(
                height: isCompact ? 46 : 54,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    (isCompact ? 46.0 : 54.0) / 2,
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF04192B), Color(0xFF010A14)],
                  ),
                  border: Border.all(
                    color: const Color(0xFF8EFAFE),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF010A14).withValues(alpha: 0.55),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      (isCompact ? 46.0 : 54.0) / 2,
                    ),
                    onTap: _isLoading ? null : _handleLogin,
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'LOGIN',
                              style: GoogleFonts.orbitron(
                                fontSize: isCompact ? 14 : 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2.0,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: isCompact ? 14 : 24),

              // Forgot Password?
              Center(
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot Password?',
                    style: GoogleFonts.outfit(
                      fontSize: isCompact ? 12 : 13,
                      color: const Color(0xFFE2E8F0),
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.60),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: isCompact ? 10 : 16),

              // Create an Account Link
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const SignupScreen(),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) => FadeTransition(opacity: animation, child: child),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Create an Account',
                      style: GoogleFonts.outfit(
                        fontSize: isCompact ? 13 : 14.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF00F0FF),
                        letterSpacing: 0.3,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.60),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
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
    );
  }
}

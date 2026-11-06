import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/services/auth_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase if publishable key is provided
  if (SupabaseConfig.publishableKey != 'PLACEHOLDER_KEY' &&
      SupabaseConfig.publishableKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.publishableKey,
      );
    } catch (e) {
      debugPrint('Supabase initialization failed: $e');
    }
  }

  runApp(const ProviderScope(child: EvMasterApp()));
}

class EvMasterApp extends StatelessWidget {
  const EvMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = AuthService().isAuthenticated;

    return MaterialApp(
      title: 'EV-MASTER',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: isAuthenticated ? const DashboardScreen() : const LoginScreen(),
    );
  }
}

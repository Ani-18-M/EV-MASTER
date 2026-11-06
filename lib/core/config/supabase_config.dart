import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://bclnnckjmikihdnvovju.supabase.co';
  
  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_vnY5wUpYqfEhkfCVVPLyEA_5f73nw3r',
  );

  static SupabaseClient get client => Supabase.instance.client;
}

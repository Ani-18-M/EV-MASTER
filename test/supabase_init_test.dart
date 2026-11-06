import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Supabase can be initialized with credentials', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Test if SupabaseClient initializes
    final client = SupabaseClient(
      'https://bclnnckjmikihdnvovju.supabase.co',
      'sb_publishable_vnY5wUpYqfEhkfCVVPLyEA_5f73nw3r',
    );
    expect(client, isNotNull);
  });
}

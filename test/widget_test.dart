import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:pos_app/app.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'test-key',
    );
  });

  testWidgets('App boots and redirects unauthenticated users to login', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PosApp()));
    await tester.pumpAndSettle();

    expect(find.text('Masuk'), findsOneWidget);
  });
}

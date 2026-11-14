import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pos_app/app.dart';

void main() {
  testWidgets('App boots and redirects unauthenticated users to login', (tester) async {
    // No stored session (ApiClient.restoreSession not called) -> router sends to /login.
    await tester.pumpWidget(const ProviderScope(child: PosApp()));
    await tester.pumpAndSettle();

    expect(find.text('Masuk'), findsOneWidget);
  });
}

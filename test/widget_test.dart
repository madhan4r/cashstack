import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cashstack/app.dart';
import 'package:cashstack/core/storage/shared_preferences_provider.dart';

void main() {
  testWidgets('App boots and shows the splash screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const CashStackApp(),
      ),
    );
    await tester.pump();

    expect(find.text('CashStack'), findsWidgets);
  });
}

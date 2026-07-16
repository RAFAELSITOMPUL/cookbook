import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookbook_plus/main.dart';
import 'package:cookbook_plus/constants/app_constants.dart';

void main() {
  testWidgets('Splash Screen displays App Name', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CookBookAppWrapper());

    // Verify that Splash Screen shows the app name.
    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
  });
}

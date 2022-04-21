// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:integration_test/integration_test.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
// import 'package:vplus/main.dart' as app;

// //flutter driver \
// //--driver=test_driver/integration_test_driver/dart \
// //--target=integration_test/
// void main() {
//   group('app test', () {
//     IntegrationTestWidgetsFlutterBinding.ensureInitialized();

//     testWidgets('full app test', (tester) async {
//       app.main();

//       Future.delayed(Duration(seconds: 1));
//       await tester.pumpAndSettle();
//       final welcomeLoginButton = find.byKey(Key('welcomeLoginButton'));
//       Future.delayed(Duration(seconds: 1));
//       await tester.tap(welcomeLoginButton);

//       await tester.pumpAndSettle();

//       final phoneNumberField = find.byType(IntlPhoneField);
//       final passwordField = find.byKey(Key('loginPasswordInput'));

//       await tester.enterText(phoneNumberField, '412345678');
//       await tester.enterText(passwordField, '1234567');
//       await tester.pumpAndSettle();

//       final loginButton = find.byKey(Key('loginPageLoginButton'));
//       await tester.tap(loginButton);
//       await tester.pumpAndSettle();

//       final searchStoresBar = find.byKey(Key('searchStoresBar'));
//       expect(tester.getSemantics(searchStoresBar), matchesSemantics(
//         hasTapAction: true
//       ));
//     });
//   });
// }

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:hive/hive.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiUserHelper.dart';
import 'package:vplus_merchant_app/helpers/appConfigHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/apiUser.dart';
import 'package:vplus_merchant_app/providers/campaign_provider.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/providers/current_order_provider.dart';
import 'package:vplus_merchant_app/providers/current_printer_provider.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/providers/currentuser_provider.dart';
import 'package:vplus_merchant_app/providers/kds_provider.dart';
import 'package:vplus_merchant_app/providers/orderlist_provider.dart';
import 'package:vplus_merchant_app/providers/current_orderStatus_provider.dart';
import 'package:vplus_merchant_app/providers/printer_order_list_provider.dart';
import 'package:vplus_merchant_app/providers/report_provider.dart';
import 'package:vplus_merchant_app/screens/auth/newPasswordForm.dart';
import 'package:vplus_merchant_app/screens/auth/signin.dart';
import 'package:vplus_merchant_app/screens/auth/signup.dart';
import 'package:vplus_merchant_app/screens/auth/smsVerify.dart';
import 'package:vplus_merchant_app/screens/auth/smsVerifyResetPassword.dart';
import 'package:vplus_merchant_app/screens/home/home_screen.dart';
import 'package:vplus_merchant_app/screens/profile/profilePage.dart';
import 'package:vplus_merchant_app/screens/welcome.dart';
import 'package:vplus_merchant_app/widgets/network_error.dart';
import 'helpers/certHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'helpers/packageInfo.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vplus_merchant_app/screens/store/store_list.dart';
import 'package:vplus_merchant_app/screens/store/store_config.dart';
import 'package:vplus_merchant_app/screens/auth/updatePassword.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/screens/store/store_profile.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SentryFlutter.init((options) {
    options.dsn =
        'https://b2bf101c2d894dbd8eefc64826ecf1c5@o513211.ingest.sentry.io/5614662';
  }, appRunner: () async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    packageInfo = await PackageInfo.fromPlatform();
    // change the status bar color to material color [green-400]
    await FlutterStatusbarcolor.setStatusBarColor(Colors.grey);
    if (useWhiteForeground(Colors.grey)) {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    } else {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
    }

    HttpOverrides.global = new MyHttpOverrides();

    await Hive.initFlutter();

    setupLocator();

    // set app environment { test, dev, prod }
    AppConfigHelper.setEnvironment(Environment.test);

    runApp(Phoenix(child: MyApp()));
  });
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }

  static const platform = const MethodChannel('KillIt');

  static void killAndroidAndRestartApp(BuildContext context) async {
    await platform.invokeMethod('KillIt');
  }

  static void reStartAllWidgets(context) {
    context.findAncestorStateOfType<MyAppState>().restartApp();
  }

  static void reDrawAllWidget(BuildContext context) {
    main();
  }
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => CurrentUserProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => CurrentStoresProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => CurrentMenuProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => CurrentOrderProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => Current_OrderStatus_Provider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => OrderListProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => CurrentPrinterProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => PrinterOrderListProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => ReportProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => KDSProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => CampaignProvider(),
          )
        ],
        builder: (ctx, widget) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return OrientationBuilder(
                builder: (context, orientation) {
                  SizeHelper().init(constraints, orientation);
                  return MaterialApp(
                    // Support Lanaguges
                    supportedLocales: [
                      const Locale('en', ''), //English
                      const Locale.fromSubtags(languageCode: 'zh'), //Chinese
                    ],

                    localizationsDelegates: [
                      //class which loads the translations from JSON files
                      AppLocalizationHelper.delegate,
                      // localizations for basic text for material widgets
                      GlobalMaterialLocalizations.delegate,
                      // localizations for text direction
                      GlobalWidgetsLocalizations.delegate,

                      GlobalCupertinoLocalizations.delegate,
                    ],

                    //Return a locale which will be use by the app
                    localeResolutionCallback: (locale, supportedLocales) {
                      //Check if the current device locale is supported
                      for (var supportedLocale in supportedLocales) {
                        if (supportedLocale.languageCode ==
                            locale.languageCode) {
                          return supportedLocale;
                        }
                      }
                      // if is not suppported, return the first language in the list: English
                      return supportedLocales.first;
                    },

                    debugShowCheckedModeBanner: false,
                    title: 'VPlus',
                    home: FutureBuilder(
                        future:
                            Provider.of<CurrentUserProvider>(ctx, listen: false)
                                .checkExistingLoginFuture,
                        builder: (ctx, data) {
                          if (data.connectionState != ConnectionState.done)
                            return Container();

                          if (data.hasError) {
                            return NetErrorWidget(callback: null);
                          }
                          ApiUser user = data.data;

                          if (user != null) {
                            return (ApiUserHelper.isAdmin(user))
                                ? StoreList()
                                : HomeScreen();
                          }
                          return SignInPage();
                        }),
                    //initialRoute: loggedInUser == null ? 'WelcomePage' : 'HomePage',
                    routes: {
                      'WelcomePage': (context) => WelcomeScreen(),
                      'SignupPage': (context) => SignUpPage(),
                      'HomePage': (context) => HomeScreen(),
                      // // 'RewardsPage': (context) => RewardsScreen(),
                      // 'DetailsPage': (context) => Details(),
                      'SignInPage': (context) => SignInPage(),
                      "smsVerify": (context) => SmsVerifyScreen(),
                      "newPasswordFormPage": (context) => NewPasswordFormPage(),
                      "resetpassword": (context) =>
                          SmsVerifyResetPasswordScreen(),
                      "StoreList": (context) => StoreList(),
                      "StoreConfig": (context) => StoreConfig(),
                      "UpdatePassword": (context) => UpdatePasswordPage(),
                      "ProfilePage": (context) => ProfilePage(),
                    },
                    onGenerateRoute: (RouteSettings settings) {
                      switch (settings.name) {
                        case 'StoreProfile':
                          return SlideFromRightRoute(page: StoreProfile());
                          break;
                      }
                      return SlideFromRightRoute(page: Container());
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

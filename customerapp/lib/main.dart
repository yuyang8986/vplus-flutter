import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:vplus/config/config.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/helper/appConfigHelper.dart';
import 'package:vplus/providers/campaign_provider.dart';
import 'package:vplus/providers/carousel_provider.dart';
import 'package:vplus/providers/coupon_provider.dart';
import 'package:vplus/providers/driver_order_list_provider.dart';
import 'package:vplus/providers/groceries_item_provider.dart';
import 'package:vplus/providers/order_list_provider.dart';
import 'package:vplus/providers/current_menu_provider.dart';
import 'package:vplus/providers/current_order_provider.dart';
import 'package:vplus/providers/current_store_provider.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/providers/payment_provider.dart';
import 'package:vplus/providers/rewards_provider.dart';
import 'package:vplus/providers/storeList_provider.dart';
import 'package:vplus/providers/user_address_provider.dart';
import 'package:vplus/screens/auth/initUserPassword.dart';
import 'package:vplus/screens/order/payment/payment_success_page.dart';
import 'package:vplus/screens/order/table_bottom_bar/bottom_bar_utils.dart';
import 'package:vplus/screens/stores/changeUserLocationPage.dart';
import 'package:vplus/screens/stores/storeListPage.dart';
import 'package:vplus/screens/visit/detail.dart';
import 'package:vplus/screens/home/home.dart';
import 'package:vplus/screens/auth/newPasswordForm.dart';
import 'package:vplus/screens/auth/signin.dart';
import 'package:vplus/screens/auth/signup.dart';
import 'package:vplus/screens/auth/smsVerify.dart';
import 'package:vplus/screens/auth/smsVerifyResetPassword.dart';
import 'package:vplus/screens/welcome.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'helper/appLocalizationHelper.dart';
import 'helper/packageInfo.dart';
import 'helper/sizeHelper.dart';
import 'screens/home/home.dart';
import 'screens/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  packageInfo = await PackageInfo.fromPlatform();
  // change the status bar color to material color [green-400]

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Color for Android
      statusBarBrightness:
          Brightness.dark // Dark == white status bar -- for IOS.
      ));

  await Hive.initFlutter();

  // set app environment { test, dev, prod }
  AppConfigHelper.setEnvironment(Environment.test);
  StripePayment.setOptions(StripeOptions(
      publishableKey: AppConfigHelper.getStripePublishableKey,
      merchantId: IOS_PAYMENT_MERCHANT_ID,
      androidPayMode: AppConfigHelper.getAndroidPayMode));
  // ignore CERTIFICATE_VERIFY_FAILED for debug environment
  HttpOverrides.global = new DebugHttpOverrides();
  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => CurrentUserProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => RewardsProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CurrentMenuProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CurrentOrderProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => BottomBarEventProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => StoreListProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PaymentProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CurrentStoreProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => OrderListProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CampaignProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DriverOrderListProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => UserAddressProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => GroceriesItemProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CouponProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CarouselProvider(),
        ),
      ],
      builder: (ctx, widget) {
        return LayoutBuilder(builder: (context, constraints) {
          return OrientationBuilder(builder: (context, orientation) {
            SizeHelper().init(constraints, orientation);
            return OverlaySupport.global(
              child: MaterialApp(
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
                    if (supportedLocale.languageCode == locale.languageCode) {
                      return supportedLocale;
                    }
                  }
                  // if is not suppported, return the first language in the list: English
                  return supportedLocales.first;
                },

                debugShowCheckedModeBanner: false,
                title: 'VPlus',
                home: FutureBuilder(
                    future: Provider.of<CurrentUserProvider>(ctx, listen: false)
                        .checkExistingLoginFuture,
                    builder: (ctx, data) {
                      if (!data.hasData) return Container();
                      bool userExist = data.data;
                      if (userExist) {
                        return HomeScreen();
                      }
                      return WelcomeScreen();
                    }),
                //initialRoute: loggedInUser == null ? 'WelcomePage' : 'HomePage',
                routes: {
                  //'/': (context) => WelcomeScreen(),
                  'WelcomePage': (context) => WelcomeScreen(),
                  'SignupPage': (context) => SignUpPage(),
                  'HomePage': (context) => HomeScreen(),
                  // 'RewardsPage': (context) => RewardsScreen(),
                  'DetailsPage': (context) => Details(),
                  'SignInPage': (context) => SignInPage(),
                  "smsVerify": (context) => SmsVerifyScreen(),
                  "newPasswordFormPage": (context) => NewPasswordFormPage(),
                  "resetpassword": (context) => SmsVerifyResetPasswordScreen(),
                  //"profilePage": (context) => ProfilePage(),
                  "StoreListPage": (context) => StoreListPage(),
                  "PaymentSuccessPage": (context) => PaymentSuccessPage(),
                  "ChangeAddressPage": (context) => ChangeAddressPage(),
                  "initUserPasswordPage": (context) => InitUserPassword(),
                },
              ),
            );
          });
        });
      },
    );
  }
}

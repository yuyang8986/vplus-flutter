import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hive/hive.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:signalr_core/signalr_core.dart' as s;
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/fcmHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/printerHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/signalrHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/helpers/timerHelper.dart';
import 'package:vplus_merchant_app/models/apiUser.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/providers/current_orderStatus_provider.dart';
import 'package:vplus_merchant_app/providers/current_printer_provider.dart';
import 'package:vplus_merchant_app/providers/currentuser_provider.dart';
import 'package:vplus_merchant_app/providers/home_screen_provider.dart';
import 'package:vplus_merchant_app/providers/orderlist_provider.dart';
import 'package:vplus_merchant_app/screens/KDS/kds_homepage.dart';
import 'package:vplus_merchant_app/screens/report/report_page.dart';
import 'package:vplus_merchant_app/screens/menu/menu_list_screen.dart';
import 'package:vplus_merchant_app/screens/menu/read_only_dialog.dart';
import 'package:vplus_merchant_app/screens/order/order_list/orderlist_HomePage.dart';
import 'package:vplus_merchant_app/screens/order/order_type_screen.dart';
import 'package:vplus_merchant_app/screens/qr/qrgenerator.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/widgets/network_error.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  OrderListProvider _orderListProviderInstance;
  Future _getMenuFromAPIFuture;
  int storeId;
  ApiUserRole userRole;
  @override
  void initState() {
    _orderListProviderInstance =
        Provider.of<OrderListProvider>(context, listen: false);
    userRole =
        Provider.of<CurrentUserProvider>(context, listen: false).getUserRole();
    storeId = Provider.of<CurrentStoresProvider>(context, listen: false)
        .getStoreId(context);
    if (storeId != null)
      _getMenuFromAPIFuture =
          Provider.of<CurrentMenuProvider>(context, listen: false)
              .getMenuFromAPI(context, storeId);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (context == null) return;
      await SignalrHelper.openHubConnection(context);
      await FCMHelper.init(context);
      await SignalrHelper.registerDevice(storeId, context);

      await Provider.of<CurrentStoresProvider>(context, listen: false)
          .getSingleStoreById(context, storeId);

      await Provider.of<CurrentPrinterProvider>(context, listen: false)
          .reconnectKnownPrinter();
    });
    WidgetsBinding.instance.addObserver(this);

    //TimerHelper.initTimer(context, TimerType.confirmOrderReminder);

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        // TimerHelper.initTimer(context);
        // try {
        //   if (context == null) return;

        //   //if (SignalrHelper.hubConnection?.state !=
        //     //  s.HubConnectionState.connected) {
        //     // Helper().showToastSuccess("Reconnecting");
        //     //await SignalrHelper.openHubConnection(context);
        //     //await SignalrHelper.registerDevice(storeId, context);
        //     await Provider.of<OrderListProvider>(context, listen: false)
        //         .getOrderListFromAPI(
        //             context,
        //             Provider.of<CurrentMenuProvider>(context, listen: false)
        //                 .getStoreMenuId,
        //             true,
        //             1);
        //     // Helper().showToastSuccess("Reconnected");
        //   //}
        // } catch (e) {
        //   Helper().showToastError(AppLocalizationHelper.of(context)
        //       .translate("FailedToConnectServerNote"));

        //   //Re-init all settings
        //   pushNewScreen(context, screen: HomeScreen());
        //   break;
        // }

        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        try {
          SignalrHelper.hubConnection?.off("NewOrder");
          SignalrHelper.hubConnection?.stop();
        } catch (e) {
          // Helper().showToastError(e.toString());
        }

        // TimerHelper.cancelTimer();
        break;
      case AppLifecycleState.paused:
        print("app in paused");

        //TimerHelper.cancelTimer();

        break;
      case AppLifecycleState.detached:
        print("app in detached");

        // TimerHelper.cancelTimer();

        //Phoenix.rebirth(context);
        break;
    }
  }

  @mustCallSuper
  @override
  void dispose() {
    // cleanup data before switch store
    _orderListProviderInstance.clearOrderList();
    WidgetsBinding.instance.removeObserver(this);
    //Phoenix.rebirth(context);
    //TimerHelper.cancelTimer();
    super.dispose();
  }

  PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  List<PersistentBottomNavBarItem> _navBarsItems() {
    switch (userRole) {
      case ApiUserRole.OrganizationAdmin:
        return getAdminTabs();
      case ApiUserRole.OrganizationStaff:
        return getStaffTabs();
      // case ApiUserRole.Kitchen:
      //   return getKitchenTabs();
      default:
        return getAdminTabs();
    }
  }

  getStaffTabs() {
    return [
      // PersistentBottomNavBarItem(
      //   icon: Icon(
      //     Icons.restaurant,
      //     size: SizeHelper.isMobilePortrait
      //         ? 8 * SizeHelper.imageSizeMultiplier
      //         : 3 * SizeHelper.textMultiplier,
      //   ),
      //   title: (AppLocalizationHelper.of(context)
      //       .translate("NavigationBarOrderLabel")),
      //   activeColor: Colors.black,
      //   inactiveColor: Colors.grey,
      //   contentPadding: 10.0,
      // ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.receipt,
          size: SizeHelper.isMobilePortrait
              ? 8 * SizeHelper.imageSizeMultiplier
              : 3 * SizeHelper.textMultiplier,
        ),
        title: (AppLocalizationHelper.of(context)
            .translate("NavigationBarOrderListLabel")),
        activeColor: Colors.black,
        inactiveColor: Colors.grey,
        contentPadding: 10.0,
      ),
    ];
  }

  // getKitchenTabs() {
  //   return [
  //     PersistentBottomNavBarItem(
  //       icon: Icon(
  //         Icons.restaurant,
  //         size: SizeHelper.isMobilePortrait
  //             ? 8 * SizeHelper.imageSizeMultiplier
  //             : 3 * SizeHelper.textMultiplier,
  //       ),
  //       title: (AppLocalizationHelper.of(context)
  //           .translate("NavigationBarKDSLabel")),
  //       activeColor: Colors.black,
  //       inactiveColor: Colors.grey,
  //       contentPadding: 10.0,
  //     ),
  //     PersistentBottomNavBarItem(
  //       icon: Icon(
  //         Icons.qr_code,
  //         size: SizeHelper.isMobilePortrait
  //             ? 8 * SizeHelper.imageSizeMultiplier
  //             : 3 * SizeHelper.textMultiplier,
  //       ),
  //       title: (AppLocalizationHelper.of(context)
  //           .translate("NavigationBarQRLabel")),
  //       activeColor: Colors.black,
  //       inactiveColor: Colors.grey,
  //       contentPadding: 10.0,
  //     ),
  //   ];
  // }

  getAdminTabs() {
    return [
      // PersistentBottomNavBarItem(
      //   icon: Icon(
      //     Icons.restaurant,
      //     size: SizeHelper.isMobilePortrait
      //         ? 8 * SizeHelper.imageSizeMultiplier
      //         : 3 * SizeHelper.textMultiplier,
      //   ),
      //   title: (AppLocalizationHelper.of(context)
      //       .translate("NavigationBarOrderLabel")),
      //   activeColor: Colors.black,
      //   inactiveColor: Colors.grey,
      //   contentPadding: 10.0,
      // ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.menu_book,
          size: SizeHelper.isMobilePortrait
              ? 8 * SizeHelper.imageSizeMultiplier
              : 3 * SizeHelper.textMultiplier,
        ),
        title: (AppLocalizationHelper.of(context)
            .translate("NavigationBarMenuLabel")),
        activeColor: Colors.black,
        inactiveColor: Colors.grey,
        contentPadding: 10.0,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.receipt,
          size: SizeHelper.isMobilePortrait
              ? 8 * SizeHelper.imageSizeMultiplier
              : 3 * SizeHelper.textMultiplier,
        ),
        title: (AppLocalizationHelper.of(context)
            .translate("NavigationBarOrderListLabel")),
        activeColor: Colors.black,
        inactiveColor: Colors.grey,
        contentPadding: 10.0,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.qr_code,
          size: SizeHelper.isMobilePortrait
              ? 8 * SizeHelper.imageSizeMultiplier
              : 3 * SizeHelper.textMultiplier,
        ),
        title: (AppLocalizationHelper.of(context)
            .translate("NavigationBarQRLabel")),
        activeColor: Colors.black,
        inactiveColor: Colors.grey,
        contentPadding: 10.0,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.insights,
          size: SizeHelper.isMobilePortrait
              ? 8 * SizeHelper.imageSizeMultiplier
              : 3 * SizeHelper.textMultiplier,
        ),
        title: (AppLocalizationHelper.of(context)
            .translate("NavigationBarReportLabel")),
        activeColor: Colors.black,
        inactiveColor: Colors.grey,
        contentPadding: 10.0,
      )
    ];
  }

  List<Widget> _buildScreens() {
    switch (userRole) {
      case ApiUserRole.OrganizationAdmin:
        return getAdminScreens();
      case ApiUserRole.OrganizationStaff:
        return getStaffScreens();
      // case ApiUserRole.Kitchen:
      //   return getKitchenScreens();
      default:
        return getAdminScreens();
    }
  }

  getAdminScreens() {
    return [
      // OrderTypeScreen(),
      MenuListScreen(),
      OrderListView_Active(), //Order List Page
      // buttonSection,
      QRGenerator(), // QR
      ReportScreen(), // Report
    ];
  }

  getStaffScreens() {
    return [
      // OrderTypeScreen(),
      // MenuListScreen(),
      OrderListView_Active(), //Order List Page
      // buttonSection,
      //QRGenerator(), // QR
      //QrEntranceScreen(), // Report
    ];
  }

  // getKitchenScreens() {
  //   return [
  //     OrderTypeScreen(),
  //     QRGenerator(), // QR
  //   ];
  // }

  @override
  Widget build(BuildContext context) {
    ScreenHelper.lockOrientation(context);
    return SafeArea(
        bottom: false,
        top: true,
        child: WillPopScope(
          onWillPop: _willPopCallback,
          child: Scaffold(
              resizeToAvoidBottomInset: true,
              body: FutureBuilder(
                  future: _getMenuFromAPIFuture,
                  builder: (ctx, asyncData) {
                    if (asyncData.connectionState != ConnectionState.done)
                      return Center(child: CircularProgressIndicator());

                    if (asyncData.hasError) {
                      return Center(
                        child: NetErrorWidget(callback: null),
                      );
                    }
                    return _homeScreenContent();
                  })),
        ));
  }

  Widget _homeScreenContent() {
    /// PersistentTabView requires at least 2 tabs. So for kitchen acct,
    /// do not use PersistentTabView
    return (userRole == ApiUserRole.StoreKitchen)
        ? KDSHomePage()
        : PersistentTabView(
            context,
            controller: _controller,
            onItemSelected: (value) {
              // if (userRole == ApiUserRole.OrganizationAdmin && value == 1) {
              // show read only menu notice
              // bool isMenuLocked =
              //     Provider.of<OrderListProvider>(context, listen: false)
              //         .isMenuLocked(context); // this popup shows once only
              // bool hasShownReadOnlyDialog =
              //     Provider.of<CurrentMenuProvider>(context, listen: false)
              //         .getHasShownReadOnlyDialog;
              // if (isMenuLocked && hasShownReadOnlyDialog == false) {
              //   Provider.of<CurrentMenuProvider>(context, listen: false)
              //       .setShownReadOnlyDialog();
              //   showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return ReadOnlyDialog();
              //       });
              // }
              // }
              _clearCurrentViewOrderWhenSwitchTab(value, context);
              print(value);
            },
            screens: _buildScreens(),
            items: _navBarsItems(),
            confineInSafeArea: true,
            backgroundColor: Colors.white,
            handleAndroidBackButtonPress: true,
            resizeToAvoidBottomInset:
                true, // This needs to be true if you want to move up the screen when keyboard appears.
            stateManagement: true,
            hideNavigationBarWhenKeyboardShows:
                true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument.

            popAllScreensOnTapOfSelectedTab: true,

            navBarStyle: NavBarStyle
                .style3, // Choose the nav bar style with this property.
            navBarHeight: SizeHelper.isMobilePortrait
                ? 10 * SizeHelper.heightMultiplier
                : 10 * SizeHelper.widthMultiplier,
          );
  }

  _clearCurrentViewOrderWhenSwitchTab(int tabIndex, BuildContext context) {
    bool isAdmin = userRole == ApiUserRole.OrganizationAdmin;
    if ((isAdmin && tabIndex != 2) || (!isAdmin && tabIndex != 1)) {
      // admin or staff not on order list page
      if (ScreenHelper.isLandScape(context) &&
          Provider.of<Current_OrderStatus_Provider>(context, listen: false)
                  .getOrder !=
              null) {
        Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .setOrder(context, null, false);
      }
    }
  }

  Future<bool> _willPopCallback() async {
    // var hlp = Helper();
    // hlp.showToastError("Please click again to exit.");
    return false;
  }
}

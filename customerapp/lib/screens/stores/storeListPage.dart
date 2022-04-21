import 'package:flutter/material.dart';
import 'package:geocoder/model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/store.dart';
import 'package:vplus/providers/current_store_provider.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/providers/storeList_provider.dart';
import 'package:vplus/screens/stores/SearchStore/search_store_bar.dart';
import 'package:vplus/screens/stores/StoreCampaignsList/live_campaigns.dart';
import 'package:vplus/screens/stores/StoreOrderPage/storeOrderPage.dart';
import 'package:vplus/screens/stores/store_type_bar.dart';
import 'package:vplus/screens/stores/storelist_cuisine_listview.dart';
import 'package:vplus/screens/stores/store_listtile.dart';
import 'package:vplus/widgets/emptyView.dart';
import 'package:vplus/widgets/userLocation_bar.dart';
import 'package:vplus/widgets/appBar.dart';
import 'package:vplus/widgets/silders.dart';

class StoreListPage extends StatefulWidget {
  @override
  _StoreListPageState createState() => _StoreListPageState();
}

class _StoreListPageState extends State<StoreListPage>
    with WidgetsBindingObserver {
  bool isLoading = false;

  StoreListButtonType _selectedType;

  bool sortStoreListByDistance;
  List<int> businessCatTypes;
  int pageNumber;

  List<Store> storeList;
  Coordinates coord;

  ScrollController listViewController = new ScrollController();

  @override
  void initState() {
    _selectedType = StoreListButtonType.PickUp;
    pageNumber = 1;
    sortStoreListByDistance = true;
    businessCatTypes = null;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        isLoading = true;
      });
      coord = await Provider.of<CurrentUserProvider>(context, listen: false)
          .initUserGeoInto(context);
      await Provider.of<StoreListProvider>(context, listen: false)
          .getStoreListFromAPI(context, businessCatTypes, pageNumber,
              sortStoreListByDistance, coord);
      setState(() {
        isLoading = false;
      });
    });

    initScrollController(listViewController);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        try {
          if (context == null) return;
          _selectedType = StoreListButtonType.PickUp;
          pageNumber = 1;
          sortStoreListByDistance = true;
          businessCatTypes = null;
          await Provider.of<StoreListProvider>(context, listen: false)
              .getStoreListFromAPI(context, businessCatTypes, pageNumber,
                  sortStoreListByDistance, coord,
                  isReFresh: true);
        } catch (e) {
          break;
        }

        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  didChangeDependencies() {
    _selectedType = StoreListButtonType.PickUp;
    pageNumber = 1;
    sortStoreListByDistance = true;
    businessCatTypes = null;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        isLoading = true;
      });
      coord = await Provider.of<CurrentUserProvider>(context, listen: false)
          .initUserGeoInto(context);
      await Provider.of<StoreListProvider>(context, listen: false)
          .getStoreListFromAPI(context, businessCatTypes, pageNumber,
              sortStoreListByDistance, coord);
      setState(() {
        isLoading = false;
      });
    });

    initScrollController(listViewController);
    super.didChangeDependencies();
  }

  @mustCallSuper
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        "${AppLocalizationHelper.of(context).translate("Stores")}",
        true,
        context: context,
      ),
      body: ModalProgressHUD(
          inAsyncCall: isLoading,
          progressIndicator: CircularProgressIndicator(),
          child: RefreshIndicator(
            onRefresh: () async {
              _selectedType = StoreListButtonType.PickUp;
              pageNumber = 1;
              sortStoreListByDistance = true;
              businessCatTypes = null;
              coord =
                  await Provider.of<CurrentUserProvider>(context, listen: false)
                      .initUserGeoInto(context);
              await Provider.of<StoreListProvider>(context, listen: false)
                  .getStoreListFromAPI(context, businessCatTypes, pageNumber,
                      sortStoreListByDistance, coord,
                      isReFresh: true);
            },
            child: SingleChildScrollView(
                controller: this.listViewController,
                child: Container(
                    child: Column(children: [
                  body(context),
                ]))),
          )),
    );
  }
  // Future<void> _onRefresh() async {
  //   coord = await Provider.of<CurrentUserProvider>(context, listen: false)
  //       .initUserGeoInto(context);
  //   await Provider.of<StoreListProvider>(context, listen: false)
  //       .getStoreListFromAPI(context, businessCatTypes, pageNumber,
  //       sortStoreListByDistance, coord);
  //   return;
  // }

  Future<void> initScrollController(ScrollController _controller) async {
    _controller.addListener(() async {
      if (_controller.position.atEdge) {
        // Buttom of the pag
        if (_controller.position.pixels != 0) {
          print("Reach the End");
          bool hasNextPage;
          setState(() {
            isLoading = true;
          });
          hasNextPage = Provider.of<StoreListProvider>(context, listen: false)
              .getHasNextPage;
          if (hasNextPage) {
            pageNumber += 1;
            await Provider.of<StoreListProvider>(context, listen: false)
                .getStoreListFromAPI(context, businessCatTypes, pageNumber,
                    sortStoreListByDistance, coord);
          }

          setState(() {
            isLoading = false;
          });
        } else {
          print("Reach the Top");
        }
      }
    });
  }

  Widget storeListTile(
      List<Store> storeList, BuildContext context, bool isPickup) {
    return new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: storeList
            .map((store) => InkWell(
                  onTap: () {
                    Provider.of<CurrentStoreProvider>(context, listen: false)
                        .setCurrentStore = store;
                    pushNewScreen(context,
                        screen: StoreOrderPage(),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino);
                  },
                  child: new StoreListTile(
                    store: store,
                  ),
                ))
            .toList());
  }

  Widget storeListView(bool isPickup) {
    return Consumer<StoreListProvider>(
      builder: (ctx, p, w) {
        storeList = p.getStoreList;
        return (storeList == null || storeList.isEmpty)
            ? Container()
            : Container(
                margin: EdgeInsets.symmetric(
                    horizontal: ScreenHelper.isLandScape(context)
                        ? 10
                        : SizeHelper.widthMultiplier * 1),
                child: storeListTile(storeList, context, isPickup));
      },
    );
  }

  Widget body(BuildContext context) {
    return Column(children: [
      UserLocationBar(),
      SearchStoreBar(),
      CarouselWithIndicator(),
      VEmptyView(50),
      StoreListCuisineListView(),
      VEmptyView(50),
      LiveCampaigns(),
      Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(
            left: SizeHelper.widthMultiplier * 4,
            bottom: SizeHelper.widthMultiplier * 3),
        child: Text(
          "${AppLocalizationHelper.of(context).translate("Nearby")}",
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w900,
            fontSize: SizeHelper.isMobilePortrait
                ? 2 * SizeHelper.textMultiplier
                : 2 * SizeHelper.textMultiplier,
            color: Colors.black,
          ),
        ),
      ),
      storeListView(_selectedType == StoreListButtonType.PickUp),
    ]);
  }
}

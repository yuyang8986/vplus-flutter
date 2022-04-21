import 'package:flutter/material.dart';
import 'package:geocoder/model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/store.dart';
import 'package:vplus/models/storeBusinessType.dart';
import 'package:vplus/providers/current_store_provider.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/providers/storeList_provider.dart';
import 'package:vplus/screens/stores/store_listtile.dart';

import 'StoreOrderPage/storeOrderPage.dart';

class StoreCuisineDetailPage extends StatefulWidget {
  final StoreBusinessType cuisineType;

  StoreCuisineDetailPage({this.cuisineType});

  @override
  _StoreCuisineDetailPageState createState() => _StoreCuisineDetailPageState();
}

class _StoreCuisineDetailPageState extends State<StoreCuisineDetailPage> {
  bool isLoading = false;
  List<Store> storeList;
  int pageNumber;
  bool sortStoreListByDistance;
  List<int> businessCatTypes;
  Coordinates coord;

  ScrollController listViewController = new ScrollController();

  @override
  void initState() {
    pageNumber = 1;
    sortStoreListByDistance = true;
    businessCatTypes = [widget.cuisineType.storeBusinessCatTypeId];
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        isLoading = true;
      });
      coord =
          Provider.of<CurrentUserProvider>(context, listen: false).getUserCoord;
      await Provider.of<StoreListProvider>(context, listen: false)
          .getStoreListFromAPI(context, businessCatTypes, pageNumber,
              sortStoreListByDistance, coord);
      setState(() {
        isLoading = false;
      });
    });
    initScrollController(listViewController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Provider.of<StoreListProvider>(context, listen: false)
                  .setSelectedCuisine(null);
              Provider.of<StoreListProvider>(context, listen: false)
                  .setSortedByCuisineTypeList(List<Store>());

              Navigator.of(context).pop();
            }),
        title: Text("${widget.cuisineType.catName}",
            style: GoogleFonts.lato(
                color: Colors.black, fontWeight: FontWeight.normal)),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
          inAsyncCall: isLoading,
          progressIndicator: CircularProgressIndicator(),
          child: SingleChildScrollView(
            controller: listViewController,
            child: storeListView(true),
          )),
    );
  }

  Widget getStoreList(
      List<Store> storeList, BuildContext context, bool isPickup) {
    return Consumer<StoreListProvider>(builder: (ctx, p, w) {
      storeList = p.sortedByCuisineList
          .where((element) =>
              element.storeBusinessCatIds.first == (businessCatTypes.first))
          .toList()
          .toSet()
          .toList();
      return Column(
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
                  child: StoreListTile(store: store)))
              .toList());
    });
  }

  Widget storeListView(bool isPickup) {
    return Container(
        margin: EdgeInsets.symmetric(
            horizontal: ScreenHelper.isLandScape(context)
                ? 10
                : SizeHelper.widthMultiplier * 5),
        child: getStoreList(storeList, context, isPickup));
  }

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
            List<Store> newStoreList =
                await Provider.of<StoreListProvider>(context, listen: false)
                    .getStoreListFromAPI(context, businessCatTypes, pageNumber,
                        sortStoreListByDistance, coord);
            newStoreList.forEach((element) {
              storeList.add(element);
            });
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
}

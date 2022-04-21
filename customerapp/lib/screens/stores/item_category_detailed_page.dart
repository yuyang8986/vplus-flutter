import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/menuCategory.dart';
import 'package:vplus/models/menuItem.dart';
import 'package:vplus/models/storeMenu.dart';
import 'package:vplus/providers/current_order_provider.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/providers/groceries_item_provider.dart';
import 'package:vplus/screens/order/table_bottom_bar/bottom_bar_floating_button.dart';
import 'package:vplus/screens/order/table_bottom_bar/bottom_bar_shopping_cart_popup.dart';
import 'package:vplus/screens/order/table_bottom_bar/bottom_bar_utils.dart';
import 'package:vplus/screens/stores/category_items_list_tile.dart';
import 'package:vplus/widgets/emptyView.dart';

class ItemCategoryDetailedPage extends StatefulWidget {
  final MenuCategory itemType;
  final StoreMenu currentStoreMenu;

  ItemCategoryDetailedPage({this.itemType, this.currentStoreMenu});

  @override
  _ItemCategoryDetailedPageState createState() =>
      _ItemCategoryDetailedPageState();
}

class _ItemCategoryDetailedPageState extends State<ItemCategoryDetailedPage> {
  bool isLoading = false;
  List<MenuItem> itemsWithSelectedCatList;
  ScrollController listViewController = new ScrollController();
  final double _initFabHeight = ScreenUtil().setHeight(50);
  double _fabHeight;
  double _panelHeightOpen;
  double _panelHeightClosed = ScreenUtil().setHeight(130);
  PanelController _panelController = PanelController();
  bool isCartPoped = false;

  @override
  void initState() {
    _fabHeight = _initFabHeight;
    itemsWithSelectedCatList = widget.itemType.menuItems;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentOrderProvider>(builder: (context, value, child) {
      int count = Provider.of<CurrentOrderProvider>(context, listen: false)
              .getOrder
              ?.userItems
              ?.length ??
          0;
      if (count < 1)
        _panelHeightOpen = ScreenUtil().setHeight(140);
      else if (count >= 1 &&
          count * ScreenUtil().setHeight(225) + ScreenUtil().setHeight(260) <
              MediaQuery.of(context).size.height * .75)
        _panelHeightOpen =
            count * ScreenUtil().setHeight(225) + ScreenUtil().setHeight(260);
      else
        _panelHeightOpen = MediaQuery.of(context).size.height * .75;

      Provider.of<BottomBarEventProvider>(context, listen: false)
          .setPanelController(_panelController);
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            title: Column(
              children: [
                Text(widget.itemType.menuCategoryName,
                    style: GoogleFonts.lato(
                        color: Colors.black, fontWeight: FontWeight.normal)),
                Text(widget.itemType.menuSubtitle,
                    style: GoogleFonts.lato(
                        color: Colors.black, fontWeight: FontWeight.normal))
              ],
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              ModalProgressHUD(
                  inAsyncCall: isLoading,
                  progressIndicator: CircularProgressIndicator(),
                  child: SingleChildScrollView(
                      controller: listViewController,
                      child: Container(
                        child: (itemsWithSelectedCatList == null ||
                                itemsWithSelectedCatList.isEmpty)
                            ? Center(child: Container(child: Text("There are no items")))
                            : SingleChildScrollView(
                                controller: listViewController,
                                child: Column(
                                  children: <Widget>[
                                    ListView.builder(
                                      padding: EdgeInsets.only(bottom: 100),
                                        itemCount:
                                            itemsWithSelectedCatList.length,
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder: (ctx, idx) {
                                          MenuItem menuItem =
                                              itemsWithSelectedCatList[idx];
                                          return Padding(
                                            padding: EdgeInsets.all(
                                                SizeHelper.heightMultiplier),
                                            child: CategoryItemListTile(
                                                item: menuItem,
                                                isCategory: true),
                                          );
                                        }),
                                  ],
                                ),
                              ),
                      ))),
              WEmptyView(150),
              if (Provider.of<GroceriesItemProvider>(context, listen: false)
                          .getStoreMenu !=
                      null &&
                  Provider.of<CurrentOrderProvider>(context, listen: false)
                          .getOrder
                          ?.userItems !=
                      null && Provider.of<CurrentUserProvider>(context, listen: false).getloggedInUser != null)
                 SlidingUpPanel(
                  maxHeight: _panelHeightOpen,
                  controller: _panelController,
                  minHeight: _panelHeightClosed,
                  panelBuilder: (sc) => TableShoppingCartDetails(
                      scrollController: sc, isStoreOrdering: true),
                  borderRadius: BottomBarUtils.bottomBarRadius(),
                  isDraggable: count < 1 ? false : true,
                  backdropEnabled: true,
                  onPanelOpened: () {
                    setState(() {
                      isCartPoped = true;
                    });
                  },
                  onPanelClosed: () {
                    setState(() {
                      isCartPoped = false;
                    });
                  },
                ),
              if (Provider.of<GroceriesItemProvider>(context, listen: false)
                          .getStoreMenu !=
                      null &&
                  Provider.of<CurrentOrderProvider>(context, listen: false)
                          .getOrder
                          ?.userItems !=
                      null && Provider.of<CurrentUserProvider>(context, listen: false).getloggedInUser != null)
                TableFloatingButton(
                  buttonPosition: _fabHeight - 15,
                  isPopUp: isCartPoped, // TODO change this
                ),
            ],
          ));
    });
  }
}

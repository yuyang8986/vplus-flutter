import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/formValidationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/menuCategory.dart';
import 'package:vplus_merchant_app/models/menuItem.dart';
import 'package:vplus_merchant_app/models/store.dart';
import 'package:vplus_merchant_app/models/storeMenu.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/providers/orderlist_provider.dart';
import 'package:vplus_merchant_app/screens/menu/addItem_to_category_screen.dart';
import 'package:vplus_merchant_app/screens/menu/addon_list_screen.dart';
import 'package:vplus_merchant_app/screens/order/order_table_order_menuItem_tile.dart';
import 'package:vplus_merchant_app/styles/color.dart';
import 'package:vplus_merchant_app/styles/regex.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';
import 'package:vplus_merchant_app/widgets/custom_dialog.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'package:vplus_merchant_app/screens/menu/ItemsMenuList.dart';
import 'package:vplus_merchant_app/screens/menu/menu_type_bar.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:drag_and_drop_gridview/devdrag.dart';

class MenuListScreen extends StatefulWidget {
  @override
  _MenuListScreenState createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  ScrollController _categoriesCtl = new ScrollController();
  ScrollController _food1Ctl = new ScrollController();
  ScrollController reOrderAbleGridViewScrollController = new ScrollController();

  Helper hlp = Helper();

  var organizationId;
  Store store;
  int storeId;

  var _saving = false;
  int selectedCategoryId = 0;

  bool _isInAsyncCall = false;
  CurrentMenuProvider _currentMenuProviderInstance;

  //bool isMenuLocked;

  @override
  void initState() {
    _currentMenuProviderInstance =
        Provider.of<CurrentMenuProvider>(context, listen: false);
    storeId = Provider.of<CurrentStoresProvider>(context, listen: false)
        .getSelectedStore
        .storeId;
    selectedCategoryId =
        Provider.of<CurrentMenuProvider>(context, listen: false)
            .getSelectedCategoryId;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<CurrentMenuProvider>(context, listen: false)
          .getMenuFromAPI(context, storeId);
    });
    store = Provider.of<CurrentStoresProvider>(context, listen: false)
        .getSelectedStore;
    _selectedType = MenuListButtonType.Categories;
    // isMenuLocked = Provider.of<OrderListProvider>(context, listen: false)
    //     .isMenuLocked(context);
    super.initState();
  }

  MenuListButtonType _selectedType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedCategoryId = Provider.of<CurrentMenuProvider>(context, listen: true)
        .getSelectedCategoryId;
    // isMenuLocked = Provider.of<OrderListProvider>(context, listen: true)
    //     .isMenuLocked(context);
  }

  @override
  void dispose() {
    _currentMenuProviderInstance.clearMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        width: 1080, height: 1920, allowFontScaling: false);
    return SafeArea(
      bottom: false,
      top: true,
      child: ModalProgressHUD(
        // callback: () async {
        //   int storeId =
        //       Provider.of<CurrentStoresProvider>(context, listen: false)
        //           .getSelectedStore
        //           .storeId;
        //   await Provider.of<CurrentMenuProvider>(context, listen: false)
        //       .getMenuFromAPI(context, storeId);
        // },
        inAsyncCall: _isInAsyncCall,
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: CustomAppBar.getAppBar(
            AppLocalizationHelper.of(context).translate('Menu'),
            true,
            showLogo: true,
            context: context,
            screenPage: CustomAppBar.storeMainPage,
            rightButtonIcon: store.logoUrl == null
                ? Container(
                    width: ScreenUtil().setWidth(70),
                    height: ScreenUtil().setHeight(70),
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: CircleAvatar(
                      child: Text(
                        store.storeName.substring(0, 1),
                        style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: ScreenUtil().setSp(
                                ScreenHelper.getResponsiveTitleFontSize(
                                    context))),
                      ),
                      backgroundColor: Color(
                          int.tryParse(store.backgroundColorHex) ??
                              Colors.grey.value),
                    ))
                : Container(
                    width: ScreenUtil().setWidth(70),
                    height: ScreenUtil().setHeight(70),
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(store.logoUrl),
                      backgroundColor: Color(
                          int.tryParse(store.backgroundColorHex) ??
                              Colors.grey.value),
                    ),
                  ),
          ),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MenuListTypeBar(
                menuListTypeButton: MenuListButtonType.values.map((e) {
                  return MenuListTypeButton(
                    isSelectedType: _selectedType,
                    buttonType: e,
                    buttonEvent: () {
                      setState(() {
                        _selectedType = e;
                      });
                    },
                  );
                }).toList(),
              ),
              _selectedType == MenuListButtonType.Categories
                  ? menuListRow()
                  : _selectedType == MenuListButtonType.Items
                      ? ItemsMenuList()
                      : AddonListScreen(),
            ],
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // crossAxisAlignment: CrossAxisAlignment.center,
            // ),
          ),
        ),
      ),
    );
  }

  Widget menuListRow() {
    return
        // height: SizeHelper.isMobilePortrait
        //     ? 3 * SizeHelper.heightMultiplier
        //     : (SizeHelper.isPortrait)
        //         ? 90 * SizeHelper.heightMultiplier
        //         : 60 * SizeHelper.heightMultiplier,
        Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: ScreenHelper.isLandScape(context) ? 3 : 4,
            child: menuListCategories(),
          ),
          Expanded(
            flex: ScreenHelper.isLandScape(context) ? 9 : 7,
            child: menuListMenus(),
          ),
        ],
      ),
    );
  }

  Widget menuListCategories() {
    return Consumer<CurrentMenuProvider>(builder: (ctx, p, w) {
      List<MenuCategory> categories =
          p?.getStoreMenu?.menuCategories ?? new List<MenuCategory>();
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          _categoryPlusButton(),
          Flexible(
            flex: 11,
            child: ReorderableListView(
              scrollController: _categoriesCtl,
              children:
                  categories.map((c) => _generateCategoryItem(c)).toList(),
              onReorder: (oldIndex, newIndex) async {
                if (newIndex > categories.length + 1)
                  newIndex = categories.length + 1;
                if (oldIndex < newIndex) newIndex--;
                oldIndex += 1; // fit the backend format
                newIndex += 1; // backend count index from 1

                print('oldIndex: $oldIndex , newIndex: $newIndex');
                setState(() {
                  _isInAsyncCall = true;
                });
                await Provider.of<CurrentMenuProvider>(context, listen: false)
                    .sortMenuCategory(
                        context,
                        categories
                            .firstWhere((element) => element.index == oldIndex)
                            .menuCategoryId,
                        newIndex);
                setState(() {
                  _isInAsyncCall = false;
                });
              },
            ),
          ),
        ],
      );
    });
  }

  Widget menuListMenus() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children:  [
              Flexible(flex: 1, child: _menuHeader()),
              Flexible(flex: 2, child: _menuAddItemButton()),
              Flexible(
                flex: 10,
                child: menuItemList(),
              ),
              Container(),
            ],
    );
  }

  Widget portraitMenuItemsView(List<MenuItem> menuItems) {
    return ReorderableListView(
      scrollController: _food1Ctl,
      children: menuItems.map((m) => _generateMenuItem(m)).toList(),
      onReorder: (oldIndex, newIndex) async {
        if (newIndex > menuItems.length + 1) newIndex = menuItems.length + 1;
        if (oldIndex < newIndex) newIndex--;
        oldIndex += 1; // fit the backend format
        newIndex += 1; // backend count index from 1

        print('oldIndex: $oldIndex , newIndex: $newIndex');
        setState(() {
          _isInAsyncCall = true;
        });
        await Provider.of<CurrentMenuProvider>(context, listen: false).sortItem(
            context,
            selectedCategoryId,
            menuItems
                .firstWhere((element) => element.index == oldIndex)
                .menuItemId,
            newIndex);
        setState(() {
          _isInAsyncCall = false;
        });
      },
    );
  }

  // Widget itemButtons(MenuItem menuItem){
  //   return Consumer(Curre)
  // }

  Widget landScapeMenuItemsView(List<MenuItem> menuItems) {
    return DragAndDropGridView(
      controller: reOrderAbleGridViewScrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: ScreenUtil().setHeight(10),
          crossAxisSpacing: ScreenUtil().setWidth(10),
          childAspectRatio: SizeHelper.heightMultiplier * 0.075),
      // childAspectRatio: SizeHelper.heightMultiplier * 0.045),
      padding: EdgeInsets.all(20),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return generateMenuItemLandScapeView(menuItems[index]);
      },
      onWillAccept: (oldIndex, newIndex) {
        // // Implement you own logic

        // // Example reject the reorder if the moving item's value is something specific
        // if (_imageUris[newIndex] == "something") {
        //   return false;
        // }
        return true; // If you want to accept the child return true or else return false
      },
      onReorder: (oldIndex, newIndex) async {
        // if (newIndex > menuItems.length + 1) newIndex = menuItems.length + 1;
        // if (oldIndex < newIndex) newIndex--;
        int tempOldIndex = oldIndex;
        tempOldIndex += 1;
        int tempNewIndex = newIndex;
        tempNewIndex += 1;
        // oldIndex += 1; // fit the backend format
        // newIndex += 1; // backend count index from 1

        print('oldIndex: $oldIndex , newIndex: $newIndex');
        setState(() {
          _isInAsyncCall = true;
        });

        await Provider.of<CurrentMenuProvider>(context, listen: false).sortItem(
            context,
            selectedCategoryId,
            menuItems
                .firstWhere((element) => element.index == tempOldIndex)
                .menuItemId,
            tempNewIndex);
        setState(() {
          _isInAsyncCall = false;
        });
      },
    );
  }

  Widget menuItemList() {
    return (selectedCategoryId == 0 || selectedCategoryId == null)
        ? emptyMenuItemListNotice()
        : Consumer<CurrentMenuProvider>(
            builder: (ctx, p, w) {
              List<MenuItem> menuItems =
                  p?.getSelectedMenuItems ?? new List<MenuItem>();

              return (menuItems == null || menuItems.isEmpty)
                  ? emptyMenuItemListNotice()
                  : (ScreenHelper.isLandScape(context))
                      ? landScapeMenuItemsView(menuItems)
                      : portraitMenuItemsView(menuItems);
            },
          );
  }

  Widget emptyMenuItemListNotice() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.inbox, size: ScreenUtil().setSp(120)),
          Text(
            AppLocalizationHelper.of(context)
                .translate('EmptyCategoryInfoNote'),
            style: GoogleFonts.lato(),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget generateMenuItemLandScapeView(MenuItem menuItem) {
    return menuItem.isActive
        ? Container(
            key: ValueKey(menuItem.menuItemId),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtil().setSp(20)),
              border: Border.all(
                color: Colors.grey,
                width: ScreenUtil().setSp(1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: ScreenHelper.isLandScape(context)
                          ? SizeHelper.widthMultiplier * 18
                          : ScreenHelper.isLargeScreen(context)
                              ? 80
                              : 60,
                      child: Stack(
                        children: [
                          menuItem.imageUrl == null
                              ? Center(
                                  child: CircleAvatar(
                                    radius: ScreenHelper.isLargeScreen(context)
                                        ? SizeHelper.imageSizeMultiplier * 10
                                        : SizeHelper.imageSizeMultiplier * 10,
                                    child: Text(
                                      menuItem.menuItemName.substring(0, 1),
                                      style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: SizeHelper.isMobilePortrait
                                            ? 3 * SizeHelper.textMultiplier
                                            : 5 * SizeHelper.textMultiplier,
                                      ),
                                    ),
                                    backgroundColor: appThemeColor,
                                  ),
                                )
                              : SquareFadeInImage(menuItem.imageUrl),
                          menuItem.isSoldOut == true
                              ? _soldOutLabel()
                              : Container(),
                        ],
                      ),
                      height: ScreenHelper.isLandScape(context)
                          ? SizeHelper.heightMultiplier * 11
                          : SizeHelper.heightMultiplier * 12,
                    ),
                    VEmptyView(10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                              maxWidth: ScreenUtil().setWidth(200)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${menuItem.menuItemName}',
                                // maxLines: 1,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  fontSize: SizeHelper.isMobilePortrait
                                      ? 2 * SizeHelper.textMultiplier
                                      : 2 * SizeHelper.textMultiplier,
                                ),
                                overflow: TextOverflow.clip,
                                textAlign: TextAlign.center,
                              ),
                              if (menuItem.subtitle != null &&
                                  menuItem.subtitle.length > 0)
                                Text(
                                  '${menuItem.subtitle}',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(
                                    fontStyle: FontStyle.italic,
                                    fontSize: SizeHelper.isMobilePortrait
                                        ? 1.5 * SizeHelper.textMultiplier
                                        : 1.5 * SizeHelper.textMultiplier,
                                  ),
                                ),
                              Text(
                                '${menuItem.description}',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                softWrap: true,
                                overflow: TextOverflow.clip,
                                style: GoogleFonts.lato(
                                  fontStyle: FontStyle.italic,
                                  fontSize: SizeHelper.isMobilePortrait
                                      ? 1.5 * SizeHelper.textMultiplier
                                      : 1.5 * SizeHelper.textMultiplier,
                                ),
                              ),
                              Text('\$${menuItem.price}',
                                  style: GoogleFonts.lato(
                                      textStyle: GoogleFonts.lato(
                                    fontSize: SizeHelper.isMobilePortrait
                                        ? 1.5 * SizeHelper.textMultiplier
                                        : 1.5 * SizeHelper.textMultiplier,
                                  ))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // VEmptyView(40),
                    Container(
                      // alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.open_with,
                            size: SizeHelper.isMobilePortrait
                                ? 3 * SizeHelper.textMultiplier
                                : 3 * SizeHelper.textMultiplier,
                          ),
                          WEmptyView(20),
                         
                            InkWell(
                              onTap: () {
                                removeMenuitemFromCategoryDialog(menuItem);
                              },
                              child: Icon(
                                Icons.cancel,
                                size: SizeHelper.isMobilePortrait
                                    ? 3 * SizeHelper.textMultiplier
                                    : 3 * SizeHelper.textMultiplier,
                                color: Colors.red,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Container(alignment: Alignment.center, child: itemButton),
                  ],
                ),
                onTap: () {},
              ),
            ),
          )
        : Container(
            key: ValueKey(menuItem.menuItemId),
          );
  }

  Widget _generateCategoryItem(MenuCategory c) {
    return Container(
      key: ValueKey(c.menuCategoryId),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().setSp(0)),
        border: Border.all(
          color: Colors.grey,
          width: ScreenUtil().setSp(1),
        ),
      ),
      child: ListTile(
        title: Container(
          constraints: BoxConstraints(
              maxHeight: ScreenHelper.isLargeScreen(context)
                  ? 80
                  : ScreenHelper.isLandScape(context)
                      ? 80
                      : 90),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.open_with,
                size: SizeHelper.isMobilePortrait
                    ? 3 * SizeHelper.textMultiplier
                    : 3 * SizeHelper.textMultiplier,
              ),
              VEmptyView(20),
              Container(
                alignment: Alignment.center,
                constraints: BoxConstraints(
                    maxWidth: ScreenUtil().setWidth(
                        ScreenHelper.isLandScape(context) ? 190 : 210)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${c.menuCategoryName}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontWeight: selectedCategoryId == c.menuCategoryId
                            ? FontWeight.bold
                            : null,
                        fontSize: SizeHelper.isMobilePortrait
                            ? 1.5 * SizeHelper.textMultiplier
                            : 1.5 * SizeHelper.textMultiplier,
                      ),
                    ),
                    if (c.menuSubtitle != null && c.menuSubtitle.length > 0)
                      Text(
                        '${c.menuSubtitle}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontWeight: selectedCategoryId == c.menuCategoryId
                              ? FontWeight.bold
                              : null,
                          fontSize: SizeHelper.isMobilePortrait
                              ? 1.5 * SizeHelper.textMultiplier
                              : 1.5 * SizeHelper.textMultiplier,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          print("tap on tile");
          setState(() {
            selectedCategoryId = c.menuCategoryId;
            Provider.of<CurrentMenuProvider>(context, listen: false)
                .setCurrentCategoryId(selectedCategoryId);
          });
        },
      ),
    );
  }

  Widget _generateMenuItem(MenuItem m) {
    return m.isActive == true
        ? Container(
            key: ValueKey(m.menuItemId),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtil().setSp(0)),
              border: Border.all(
                color: Colors.grey,
                width: ScreenUtil().setSp(1),
              ),
            ),
            child: ListTile(
              title: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: ScreenUtil().setWidth(
                        ScreenHelper.isLargeScreen(context) ? 200 : 200),
                    maxHeight: ScreenUtil().setHeight(
                        ScreenHelper.isLandScape(context) ? 500 : 270)),
                child: Container(
                  margin:
                      EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //img
                      itemImage(m),
                      // text and tool
                      itemText(m)
                    ],
                  ),
                ),
              ),
            ),
          )
        : Container(
            key: ValueKey(m.menuItemId),
          );
  }

  Widget _menuHeader() {
    return Consumer<CurrentMenuProvider>(builder: (ctx, p, w) {
      MenuCategory selectedCategory = p.getSelectedCategory;
      return selectedCategory.index == null
          ? emptyHeaderNotice()
          : Container(
              margin:
                  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ScreenUtil().setSp(18)),
                border: Border.all(
                  color: Colors.grey,
                  width: ScreenUtil().setSp(1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  WEmptyView(ScreenUtil().setSp(120)),

                  Expanded(
                    child: Text(
                    '${selectedCategory.menuCategoryName}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 
                           SizeHelper.isMobilePortrait
                                ? 2 * SizeHelper.textMultiplier
                                : 2 * SizeHelper.textMultiplier
                          ,
                      ),
                    ),
                  ),
                  
                    IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: ScreenUtil().setSp(
                              ScreenHelper.isLargeScreen(context) ? 20 : 50),
                        ),
                        onPressed: editCategory),
                  WEmptyView(
                      ScreenUtil().setSp(50)), // makes text looks like centered
                ],
              ),
            );
    });
  }

  Widget _categoryPlusButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(20)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().setSp(0)),
        border: Border.all(
          color: Colors.grey,
          width: ScreenUtil().setSp(1),
        ),
      ),
      child: InkWell(
        onTap: _newCategoryDialog,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
          child: Icon(
            Icons.add,
            size: ScreenUtil()
                .setSp(ScreenHelper.isLargeScreen(context) ? 40 : 80),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _menuAddItemButton() {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: ScreenUtil().setSp(10), horizontal: ScreenUtil().setSp(20)),
      width: double.infinity,
      height:
          ScreenUtil().setHeight(ScreenHelper.isLandScape(context) ? 150 : 100),
      child: Container(
        height: ScreenUtil().setHeight((!ScreenHelper.isLandScape(context))
            ? MediaQuery.of(context).size.width * 0.09
            : MediaQuery.of(context).size.width * 0.08),
        child: RaisedButton(
          onPressed: () {
            pushNewScreen(context,
                screen: AddItemsToCategoryScreen(), withNavBar: false);
          },
          textColor: Colors.white,
          color: Color(0xff5352EC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocalizationHelper.of(context).translate('AddItem'),
                style: GoogleFonts.lato(
                  fontSize: SizeHelper.isMobilePortrait
                      ? 2 * SizeHelper.textMultiplier
                      : 2 * SizeHelper.textMultiplier,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _soldOutLabel() {
    return Center(
      child: Container(
        width: ScreenUtil().setWidth(180),
        height: ScreenHelper.isLandScape(context)
            ? SizeHelper.heightMultiplier * 6
            : SizeHelper.heightMultiplier * 6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ScreenUtil().setSp(18)),
          border: Border.all(
            color: Colors.red,
            width: ScreenUtil().setSp(4),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          AppLocalizationHelper.of(context).translate('SoldOut'),
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
              color: Colors.pink,
              fontSize: ScreenHelper.isLandScape(context)
                  ? SizeHelper.textMultiplier * 2
                  : SizeHelper.textMultiplier * 2),
        ),
      ),
    );
  }

  _newCategoryDialog() async {
    TextEditingController _newCategoryNameCtrl = TextEditingController();
    TextEditingController _newSubCategoryNameCtrl = TextEditingController();
    final categoryNameDialogKey = GlobalKey<FormState>();
    await showDialog<String>(
      context: context,
      useRootNavigator: false,
      builder: (context) => Container(
        height: SizeHelper.isMobilePortrait
            ? 2.5 * SizeHelper.heightMultiplier
            : 30 * SizeHelper.widthMultiplier,
        width: SizeHelper.isMobilePortrait
            ? 25 * SizeHelper.widthMultiplier
            : 13 * SizeHelper.heightMultiplier,
        child: SingleChildScrollView(
          child: Form(
            key: categoryNameDialogKey,
            child: AlertDialog(
              // contentPadding: const EdgeInsets.all(46.0),
              content: Column(
                children: [
                  Text(
                    AppLocalizationHelper.of(context)
                        .translate('NewCategoryLabel'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                        fontSize: SizeHelper.isMobilePortrait
                            ? 2.5 * SizeHelper.textMultiplier
                            : (SizeHelper.isPortrait)
                                ? 2 * SizeHelper.textMultiplier
                                : 2 * SizeHelper.textMultiplier,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                      height: SizeHelper.isMobilePortrait
                          ? 3 * SizeHelper.heightMultiplier
                          : (SizeHelper.isPortrait)
                              ? 2.5 * SizeHelper.heightMultiplier
                              : 2.5 * SizeHelper.heightMultiplier),
                  TextField(
                    controller: _newCategoryNameCtrl,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(
                          RegExp(spceialCharactersAllowWhiteSpace)),
                    ],
                    decoration: InputDecoration(
                      // suffixIcon: Icon(FontAwesomeIcons.book),
                      isDense: true,
                      border: OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      hintText:
                          AppLocalizationHelper.of(context).translate('Title'),
                    ),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: SizeHelper.isMobilePortrait
                          ? 2 * SizeHelper.textMultiplier
                          : (SizeHelper.isPortrait)
                              ? 2.5 * SizeHelper.textMultiplier
                              : 2 * SizeHelper.textMultiplier,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(
                      height: SizeHelper.isMobilePortrait
                          ? 3 * SizeHelper.heightMultiplier
                          : (SizeHelper.isPortrait)
                              ? 2.5 * SizeHelper.heightMultiplier
                              : 2.5 * SizeHelper.heightMultiplier),
                  TextField(
                    controller: _newSubCategoryNameCtrl,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(
                          RegExp(spceialCharactersAllowWhiteSpace)),
                    ],
                    decoration: InputDecoration(
                      // suffixIcon: Icon(FontAwesomeIcons.book),
                      isDense: true,
                      border: OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      hintText: AppLocalizationHelper.of(context)
                          .translate('Subtitle'),
                    ),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: SizeHelper.isMobilePortrait
                          ? 2 * SizeHelper.textMultiplier
                          : (SizeHelper.isPortrait)
                              ? 2.5 * SizeHelper.textMultiplier
                              : 2 * SizeHelper.textMultiplier,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),

              actions: <Widget>[
                Container(
                  margin: EdgeInsets.all(15),
                  height: SizeHelper.isMobilePortrait
                      ? 4 * SizeHelper.heightMultiplier
                      : 5 * SizeHelper.widthMultiplier,
                  width: SizeHelper.isMobilePortrait
                      ? 25 * SizeHelper.widthMultiplier
                      : 20 * SizeHelper.heightMultiplier,
                  child: new RaisedButton(
                      color: Color(0xFF969FAA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                          AppLocalizationHelper.of(context).translate('Cancel'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: SizeHelper.isMobilePortrait
                                ? 1.8 * SizeHelper.textMultiplier
                                : 2 * SizeHelper.textMultiplier,
                          )),
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                ),
                Container(
                  margin: EdgeInsets.all(15),
                  height: SizeHelper.isMobilePortrait
                      ? 4 * SizeHelper.heightMultiplier
                      : 5 * SizeHelper.widthMultiplier,
                  width: SizeHelper.isMobilePortrait
                      ? 25 * SizeHelper.widthMultiplier
                      : 20 * SizeHelper.heightMultiplier,
                  child: new RaisedButton(
                      color: Color(0xFF5352EC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                          AppLocalizationHelper.of(context)
                              .translate('Confirm'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: SizeHelper.isMobilePortrait
                                ? 1.8 * SizeHelper.textMultiplier
                                : 2 * SizeHelper.textMultiplier,
                          )),
                      onPressed: () async {
                        setState(() {
                          _isInAsyncCall = true;
                        });
                        if (categoryNameDialogKey.currentState.validate()) {
                          if (_newCategoryNameCtrl.text.length <= 35 &&
                              _newSubCategoryNameCtrl.text.length <= 35) {
                            await Provider.of<CurrentMenuProvider>(context,
                                    listen: false)
                                .addMenuCategory(
                                    context,
                                    _newCategoryNameCtrl.text,
                                    _newSubCategoryNameCtrl.text);
                            StoreMenu menu = Provider.of<CurrentMenuProvider>(
                                    context,
                                    listen: false)
                                .getStoreMenu;
                            Provider.of<CurrentMenuProvider>(context,
                                    listen: false)
                                .setCurrentCategoryId(
                                    menu.menuCategories.last.menuCategoryId);
                            Navigator.of(context).pop();
                          } else {
                            var helper = Helper();
                            helper.showToastError(
                                '${AppLocalizationHelper.of(context).translate('MaximumInputExcessedAlert')}');
                          }
                        }
                        setState(() {
                          _isInAsyncCall = false;
                        });
                      }),
                ),
                new Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeHelper.isMobilePortrait
                          ? 3 * SizeHelper.imageSizeMultiplier
                          : (SizeHelper.isPortrait)
                              ? 0 * SizeHelper.imageSizeMultiplier
                              : 0 * SizeHelper.imageSizeMultiplier),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _getrenameCategoryDialogBody(BuildContext context) {
    TextEditingController _newCategoryNameCtrl = TextEditingController();
    TextEditingController _newCategorySubTitleCtrl = TextEditingController();

    _newCategoryNameCtrl.text = Provider.of<CurrentMenuProvider>(context)
        .getSelectedCategory
        .menuCategoryName;
    (Provider.of<CurrentMenuProvider>(context)
                    .getSelectedCategory
                    .menuSubtitle !=
                null &&
            Provider.of<CurrentMenuProvider>(context)
                    .getSelectedCategory
                    .menuSubtitle
                    .length >
                0)
        ? _newCategorySubTitleCtrl.text =
            Provider.of<CurrentMenuProvider>(context)
                .getSelectedCategory
                .menuSubtitle
        : _newCategorySubTitleCtrl.text = "";
    final categoryNameDialogKey = GlobalKey<FormState>();
    bool isInAsync = false;
    return StatefulBuilder(
      builder: (ctx, setPopupState) {
        return Container(
          child: ModalProgressHUD(
            inAsyncCall: isInAsync,
            opacity: 0.5,
            progressIndicator: CircularProgressIndicator(),
            child: Form(
              key: categoryNameDialogKey,
              child: Container(
                child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  // contentPadding: const EdgeInsets.all(16.0),
                  child: Container(
                    margin: EdgeInsets.all(20),
                    height: SizeHelper.isMobilePortrait
                        ? 40 * SizeHelper.heightMultiplier
                        : (SizeHelper.isPortrait)
                            ? 40 * SizeHelper.widthMultiplier
                            : 50 * SizeHelper.widthMultiplier,
                    width: SizeHelper.isMobilePortrait
                        ? 20 * SizeHelper.widthMultiplier
                        : (SizeHelper.isPortrait)
                            ? 40 * SizeHelper.widthMultiplier
                            : 50 * SizeHelper.widthMultiplier,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLocalizationHelper.of(context)
                                    .translate("EditCategoryName"),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                    fontSize: SizeHelper.isMobilePortrait
                                        ? 2.5 * SizeHelper.textMultiplier
                                        : (SizeHelper.isPortrait)
                                            ? 2 * SizeHelper.textMultiplier
                                            : 2 * SizeHelper.textMultiplier,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                  height: SizeHelper.isMobilePortrait
                                      ? 3 * SizeHelper.heightMultiplier
                                      : (SizeHelper.isPortrait)
                                          ? 2.5 * SizeHelper.heightMultiplier
                                          : 1.5 * SizeHelper.heightMultiplier),
                              Container(
                                height: SizeHelper.isMobilePortrait
                                    ? 10 * SizeHelper.heightMultiplier
                                    : (SizeHelper.isPortrait)
                                        ? 15 * SizeHelper.widthMultiplier
                                        : 12 * SizeHelper.widthMultiplier,
                                width: SizeHelper.isMobilePortrait
                                    ? 60 * SizeHelper.widthMultiplier
                                    : (SizeHelper.isPortrait)
                                        ? 30 * SizeHelper.heightMultiplier
                                        : 20 * SizeHelper.heightMultiplier,
                                child: TextField(
                                  autofocus: false,
                                  controller: _newCategoryNameCtrl,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(RegExp(
                                        spceialCharactersAllowWhiteSpace)),
                                  ],
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderSide: new BorderSide(
                                              color: Colors.grey),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      hintText: _newCategoryNameCtrl.text),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(
                                    fontSize: SizeHelper.isMobilePortrait
                                        ? 2 * SizeHelper.textMultiplier
                                        : (SizeHelper.isPortrait)
                                            ? 2.5 * SizeHelper.textMultiplier
                                            : 3 * SizeHelper.textMultiplier,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                              VEmptyView(20),
                              Container(
                                height: SizeHelper.isMobilePortrait
                                    ? 10 * SizeHelper.heightMultiplier
                                    : (SizeHelper.isPortrait)
                                        ? 15 * SizeHelper.widthMultiplier
                                        : 20 * SizeHelper.widthMultiplier,
                                width: SizeHelper.isMobilePortrait
                                    ? 60 * SizeHelper.widthMultiplier
                                    : (SizeHelper.isPortrait)
                                        ? 30 * SizeHelper.heightMultiplier
                                        : 20 * SizeHelper.heightMultiplier,
                                child: TextField(
                                  autofocus: false,
                                  controller: _newCategorySubTitleCtrl,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(RegExp(
                                        spceialCharactersAllowWhiteSpace)),
                                  ],
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderSide: new BorderSide(
                                              color: Colors.grey),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      hintText: _newCategorySubTitleCtrl.text),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(
                                    fontSize: SizeHelper.isMobilePortrait
                                        ? 2 * SizeHelper.textMultiplier
                                        : (SizeHelper.isPortrait)
                                            ? 2.5 * SizeHelper.textMultiplier
                                            : 3 * SizeHelper.textMultiplier,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(5),
                                    height: SizeHelper.isMobilePortrait
                                        ? 4 * SizeHelper.heightMultiplier
                                        : 5 * SizeHelper.widthMultiplier,
                                    width: SizeHelper.isMobilePortrait
                                        ? 25 * SizeHelper.widthMultiplier
                                        : 12 * SizeHelper.heightMultiplier,
                                    child: new RaisedButton(
                                        color: Color(0xFF969FAA),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Text(
                                            AppLocalizationHelper.of(context)
                                                .translate("Cancel"),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: SizeHelper
                                                      .isMobilePortrait
                                                  ? 1.5 *
                                                      SizeHelper.textMultiplier
                                                  : 2 *
                                                      SizeHelper.textMultiplier,
                                            )),
                                        textColor: Colors.white,
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        }),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(5),
                                    height: SizeHelper.isMobilePortrait
                                        ? 4 * SizeHelper.heightMultiplier
                                        : 5 * SizeHelper.widthMultiplier,
                                    width: SizeHelper.isMobilePortrait
                                        ? 25 * SizeHelper.widthMultiplier
                                        : 12 * SizeHelper.heightMultiplier,
                                    child: new RaisedButton(
                                        color: Color(0xFF5352EC),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Text(
                                            AppLocalizationHelper.of(context)
                                                .translate("Confirm"),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: SizeHelper
                                                      .isMobilePortrait
                                                  ? 1.5 *
                                                      SizeHelper.textMultiplier
                                                  : 2 *
                                                      SizeHelper.textMultiplier,
                                            )),
                                        onPressed: () async {
                                          if (categoryNameDialogKey.currentState
                                              .validate()) {
                                            if (_newCategoryNameCtrl
                                                        .text.length <=
                                                    35 &&
                                                _newCategorySubTitleCtrl
                                                        .text.length <=
                                                    35) {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      new FocusNode());

                                              setPopupState(() {
                                                isInAsync = true;
                                              });
                                              await Provider.of<
                                                          CurrentMenuProvider>(
                                                      context,
                                                      listen: false)
                                                  .updateMenuCategory(
                                                      context,
                                                      _newCategoryNameCtrl.text,
                                                      _newCategorySubTitleCtrl
                                                          .text);
                                              setPopupState(() {
                                                isInAsync = false;
                                              });
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                            } else {
                                              var helper = Helper();
                                              helper.showToastError(
                                                  '${AppLocalizationHelper.of(context).translate('MaximumInputExcessedAlert')}');
                                            }
                                          }
                                        }),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  _renameCategoryDialog() async {
    await showDialog<String>(
        context: context,
        // useRootNavigator: false,
        builder: (context) =>
            Consumer<CurrentMenuProvider>(builder: (context, p, w) {
              return _getrenameCategoryDialogBody(context);
            }));
  }

  editCategory() async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Consumer<CurrentMenuProvider>(builder: (context, p, w) {
            MenuCategory selectedCategory = p.getSelectedCategory;
            return Container(
              child: Dialog(
                backgroundColor: Color.fromRGBO(0, 0, 0, 0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: SizeHelper.isMobilePortrait
                            ? 18 * SizeHelper.heightMultiplier
                            : (SizeHelper.isPortrait)
                                ? 25 * SizeHelper.widthMultiplier
                                : 35 * SizeHelper.widthMultiplier,
                        width: SizeHelper.isMobilePortrait
                            ? 60 * SizeHelper.widthMultiplier
                            : (SizeHelper.isPortrait)
                                ? 40 * SizeHelper.widthMultiplier
                                : 45 * SizeHelper.widthMultiplier,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            width: 1,
                            color: Colors.grey,
                          ),
                          color: Colors.white,
                        ),
                        child: ListView(
                          padding: EdgeInsets.all(
                            SizeHelper.isMobilePortrait
                                ? SizeHelper.heightMultiplier
                                : (SizeHelper.isPortrait)
                                    ? SizeHelper.widthMultiplier
                                    : SizeHelper.widthMultiplier * 2,
                          ),
                          children: <Widget>[
                            Text('${selectedCategory.menuCategoryName}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  fontSize: SizeHelper.isMobilePortrait
                                      ? 2.5 * SizeHelper.textMultiplier
                                      : (SizeHelper.isPortrait)
                                          ? 2.5 * SizeHelper.textMultiplier
                                          : 2.5 * SizeHelper.textMultiplier,
                                )),
                            SizedBox(
                              height: SizeHelper.isMobilePortrait
                                  ? 1.5 * SizeHelper.heightMultiplier
                                  : (SizeHelper.isPortrait)
                                      ? SizeHelper.widthMultiplier
                                      : 2 * SizeHelper.widthMultiplier,
                            ),
                            Divider(
                              height: 2,
                              thickness: 2,
                            ),
                            InkWell(
                              onTap: () => _renameCategoryDialog(),
                              child: Container(
                                height: ScreenUtil().setSp(
                                    ScreenHelper.isLandScape(context)
                                        ? SizeHelper.widthMultiplier * 8
                                        : 100),
                                child: Center(
                                  child: Text(
                                    AppLocalizationHelper.of(context)
                                        .translate('RenameCategory'),
                                    style: GoogleFonts.lato(
                                      fontSize: SizeHelper.isMobilePortrait
                                          ? 2 * SizeHelper.textMultiplier
                                          : (SizeHelper.isPortrait)
                                              ? 2.5 * SizeHelper.textMultiplier
                                              : 2 * SizeHelper.textMultiplier,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              height: 2,
                              thickness: 2,
                            ),
                            InkWell(
                              onTap: () {
                                showDialog<void>(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (BuildContext context) {
                                      return confirmDeleteDialog();
                                    });
                              },
                              child: Container(
                                height: ScreenUtil().setSp(
                                    ScreenHelper.isLandScape(context)
                                        ? SizeHelper.widthMultiplier * 8
                                        : 100),
                                child: Center(
                                    child: Text(
                                        AppLocalizationHelper.of(context)
                                            .translate('DeleteCategory'),
                                        style: GoogleFonts.lato(
                                          fontSize: SizeHelper.isMobilePortrait
                                              ? 2 * SizeHelper.textMultiplier
                                              : (SizeHelper.isPortrait)
                                                  ? 2.5 *
                                                      SizeHelper.textMultiplier
                                                  : 2 *
                                                      SizeHelper.textMultiplier,
                                          color: Colors.blue,
                                        ))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: CircleAvatar(
                                backgroundColor: Colors.black,
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white, //Color(0xff343f4b),
                                  // size: 35,
                                )),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  _getConfirmDeleteDialogEvent(BuildContext context) {
    bool isInAsync = false;
    return StatefulBuilder(builder: (ctx, setPopupState) {
      return ModalProgressHUD(
          inAsyncCall: isInAsync,
          opacity: 0.5,
          progressIndicator: CircularProgressIndicator(),
          child: Container(
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child: Container(
                height: SizeHelper.isMobilePortrait
                    ? 30 * SizeHelper.heightMultiplier
                    : (SizeHelper.isPortrait)
                        ? 50 * SizeHelper.widthMultiplier
                        : 40 * SizeHelper.widthMultiplier,
                width: SizeHelper.isMobilePortrait
                    ? 20 * SizeHelper.widthMultiplier
                    : (SizeHelper.isPortrait)
                        ? 60 * SizeHelper.widthMultiplier
                        : 60 * SizeHelper.widthMultiplier,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      AppLocalizationHelper.of(context)
                          .translate("ConfirmDelete"),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: SizeHelper.isMobilePortrait
                            ? 2 * SizeHelper.textMultiplier
                            : (SizeHelper.isPortrait)
                                ? 2 * SizeHelper.textMultiplier
                                : 2 * SizeHelper.textMultiplier,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      AppLocalizationHelper.of(context)
                          .translate("PleaseConfirmToDelete"),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: SizeHelper.isMobilePortrait
                            ? 2 * SizeHelper.textMultiplier
                            : (SizeHelper.isPortrait)
                                ? 2.5 * SizeHelper.textMultiplier
                                : 2 * SizeHelper.textMultiplier,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "${AppLocalizationHelper.of(context).translate('Category')}: ${Provider.of<CurrentMenuProvider>(context).getSelectedCategory.menuCategoryName}",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: SizeHelper.isMobilePortrait
                            ? 2 * SizeHelper.textMultiplier
                            : (SizeHelper.isPortrait)
                                ? 2.5 * SizeHelper.textMultiplier
                                : 2 * SizeHelper.textMultiplier,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: SizeHelper.isMobilePortrait
                                ? 4 * SizeHelper.heightMultiplier
                                : 5 * SizeHelper.widthMultiplier,
                            width: SizeHelper.isMobilePortrait
                                ? 25 * SizeHelper.widthMultiplier
                                : 15 * SizeHelper.heightMultiplier,
                            child: new RaisedButton(
                                color: Color(0xFF969FAA),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Text('Cancel',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: SizeHelper.isMobilePortrait
                                          ? 1.5 * SizeHelper.textMultiplier
                                          : 1.5 * SizeHelper.textMultiplier,
                                    )),
                                textColor: Colors.white,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                          ),
                          Container(
                            height: SizeHelper.isMobilePortrait
                                ? 4 * SizeHelper.heightMultiplier
                                : 5 * SizeHelper.widthMultiplier,
                            width: SizeHelper.isMobilePortrait
                                ? 25 * SizeHelper.widthMultiplier
                                : 15 * SizeHelper.heightMultiplier,
                            child: new RaisedButton(
                                color: Color(0xFF5352EC),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Text('Confirm',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: SizeHelper.isMobilePortrait
                                          ? 1.5 * SizeHelper.textMultiplier
                                          : 1.5 * SizeHelper.textMultiplier,
                                    )),
                                onPressed: () async {
                                  setPopupState(() {
                                    isInAsync = true;
                                  });
                                  await Provider.of<CurrentMenuProvider>(
                                          context,
                                          listen: false)
                                      .deleteMenuCategory(context);
                                  StoreMenu menu =
                                      Provider.of<CurrentMenuProvider>(context,
                                              listen: false)
                                          .getStoreMenu;
                                  if (menu.menuCategories.isEmpty) {
                                    Provider.of<CurrentMenuProvider>(context,
                                            listen: false)
                                        .setCurrentCategoryId(0);
                                  } else {
                                    Provider.of<CurrentMenuProvider>(context,
                                            listen: false)
                                        .setCurrentCategoryId(menu
                                            .menuCategories
                                            .last
                                            .menuCategoryId);
                                  }
                                  setPopupState(() {
                                    isInAsync = false;
                                  });
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ));
    });
  }

  Widget confirmDeleteDialog() {
    return Consumer<CurrentMenuProvider>(
      builder: (context, p, w) {
        return _getConfirmDeleteDialogEvent(context);
      },
    );
  }

  Widget emptyHeaderNotice() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().setSp(18)),
        border: Border.all(
          color: Colors.grey,
          width: ScreenUtil().setSp(1),
        ),
      ),
      alignment: Alignment.center,
      child: Text('Add a category to start',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
    );
  }

  removeMenuitemFromCategoryDialog(MenuItem m) async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Consumer<CurrentMenuProvider>(builder: (context, p, w) {
            MenuCategory selectedCategory = p.getSelectedCategory;
            return CustomDialog(
              insideButtonList: [
                CustomDialogInsideButton(
                    buttonName:
                        AppLocalizationHelper.of(context).translate('Cancel'),
                    buttonColor: Colors.grey,
                    buttonEvent: () {
                      Navigator.of(context).pop();
                    }),
                CustomDialogInsideButton(
                    buttonName:
                        AppLocalizationHelper.of(context).translate('Confirm'),
                    buttonEvent: () async {
                      setState(() {
                        _isInAsyncCall = true;
                      });
                      await Provider.of<CurrentMenuProvider>(context,
                              listen: false)
                          .removeMenuItemFromCategory(context, m.menuItemId,
                              selectedCategory.menuCategoryId);
                      setState(() {
                        _isInAsyncCall = false;
                        Navigator.of(context).pop();
                      });
                    })
              ],
              child: Column(
                children: [
                  Text(
                    AppLocalizationHelper.of(context)
                        .translate('PleaseConfirmToDelete'),
                    style: GoogleFonts.lato(
                        fontSize: ScreenUtil().setSp(
                            ScreenHelper.isLandScape(context)
                                ? SizeHelper.textMultiplier * 3
                                : SizeHelper.textMultiplier * 3)),
                  ),
                  VEmptyView(20),
                  Text(
                    '${m.menuItemName}',
                    style: GoogleFonts.lato(
                        fontSize: ScreenUtil().setSp(
                            ScreenHelper.isLandScape(context)
                                ? SizeHelper.textMultiplier * 3
                                : SizeHelper.textMultiplier * 3)),
                  ),
                  VEmptyView(20),
                  Text(
                    AppLocalizationHelper.of(context).translate('From'),
                    style: GoogleFonts.lato(
                        fontSize: ScreenUtil().setSp(
                            ScreenHelper.isLandScape(context)
                                ? SizeHelper.textMultiplier * 3
                                : SizeHelper.textMultiplier * 3)),
                  ),
                  VEmptyView(20),
                  Text(
                    '${selectedCategory.menuCategoryName}?',
                    style: GoogleFonts.lato(
                        fontSize: ScreenUtil().setSp(
                            ScreenHelper.isLandScape(context)
                                ? SizeHelper.textMultiplier * 3
                                : SizeHelper.textMultiplier * 3)),
                  )
                ],
              ),
            );
          });
        });
  }

  itemImage(m) {
    return Container(
      width: ScreenUtil().setWidth(ScreenHelper.isLandScape(context)
          ? SizeHelper.heightMultiplier * 10
          : ScreenHelper.isLargeScreen(context)
              ? 165
              : 200),
      height: ScreenUtil()
          .setHeight(ScreenHelper.isLargeScreen(context) ? 240 : 185),
      // decoration: BoxDecoration(
      //     border: ScreenHelper.isLandScape(context)
      //         ? Border.all(
      //             color: Colors.grey,
      //             width: ScreenUtil().setSp(1),
      //           )
      //         : null,
      //     borderRadius:
      //         BorderRadius.all(Radius.circular(ScreenUtil().setSp(14)))),
      child: Stack(
        children: [
          m.imageUrl == null
              ? Center(
                  child: CircleAvatar(
                    radius: ScreenUtil().setSp(
                        ScreenHelper.isLargeScreen(context)
                            ? SizeHelper.imageSizeMultiplier * 6
                            : SizeHelper.imageSizeMultiplier * 30),
                    child: Center(
                      child: Text(
                        m.menuItemName.substring(0, 1),
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: SizeHelper.isMobilePortrait
                              ? 3 * SizeHelper.textMultiplier
                              : 5 * SizeHelper.textMultiplier,
                        ),
                      ),
                    ),
                    backgroundColor: Color(0xff5352ec),
                  ),
                )
              : SquareFadeInImage(m.imageUrl),
          m.isSoldOut == true ? _soldOutLabel() : Container(),
        ],
      ),
    );
  }

  itemText(MenuItem m) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setSp(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //title
            Padding(
              padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(0)),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: SizeHelper.widthMultiplier * 50,
                ),
                child: Text(
                  '${m.menuItemName}',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: SizeHelper.isMobilePortrait
                        ? 1.5 * SizeHelper.textMultiplier
                        : 2 * SizeHelper.textMultiplier,
                  ),
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            // desc and tool
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    // maxHeight: ScreenUtil().setHeight(
                    //     ScreenHelper.isLandScape(context)
                    //         ? SizeHelper.widthMultiplier * 45
                    //         : SizeHelper.widthMultiplier * 45),
                    maxWidth: ScreenUtil().setWidth(260),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: ScreenUtil().setWidth(200)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (m.subtitle != null && m.subtitle.length > 0)
                              Text(
                                '${m.subtitle}',
                                textAlign: TextAlign.start,
                                style: GoogleFonts.lato(
                                  fontStyle: FontStyle.italic,
                                  fontSize: SizeHelper.isMobilePortrait
                                      ? 1.6 * SizeHelper.textMultiplier
                                      : 2 * SizeHelper.textMultiplier,
                                ),
                              ),
                            Text(
                              '${m.description}',
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.clip,
                              style: GoogleFonts.lato(
                                fontStyle: FontStyle.italic,
                                fontSize: SizeHelper.isMobilePortrait
                                    ? 1.6 * SizeHelper.textMultiplier
                                    : 2 * SizeHelper.textMultiplier,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text('\$${m.price}',
                          style: GoogleFonts.lato(
                              textStyle: GoogleFonts.lato(
                            fontSize: SizeHelper.isMobilePortrait
                                ? 1.5 * SizeHelper.textMultiplier
                                : 2 * SizeHelper.textMultiplier,
                          ))),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.open_with,
                        size: SizeHelper.isMobilePortrait
                            ? 3 * SizeHelper.textMultiplier
                            : 3 * SizeHelper.textMultiplier,
                      ),
                      WEmptyView(25),
                     
                        InkWell(
                          onTap: () {
                            removeMenuitemFromCategoryDialog(m);
                          },
                          child: Icon(
                            Icons.cancel,
                            size: SizeHelper.isMobilePortrait
                                ? 3 * SizeHelper.textMultiplier
                                : 3 * SizeHelper.textMultiplier,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

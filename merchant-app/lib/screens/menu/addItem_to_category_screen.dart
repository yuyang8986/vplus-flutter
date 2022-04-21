import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/menuCategory.dart';
import 'package:vplus_merchant_app/models/menuItem.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/screens/menu/new_item_screen.dart';
import 'package:vplus_merchant_app/widgets/add_items_to_category_listTile.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';

class AddItemsToCategoryScreen extends StatefulWidget {
  @override
  _AddItemsToCategoryScreenState createState() =>
      _AddItemsToCategoryScreenState();
}

class _AddItemsToCategoryScreenState extends State<AddItemsToCategoryScreen> {
  MenuCategory selectedCategory;
  List<MenuItem> currentSelectedItems;
  List<MenuItem> unSelectedItems;
  TextEditingController searchBarController = new TextEditingController();
  FocusNode searchBarFocus = new FocusNode();
  ScrollController scrollController = new ScrollController();

  bool _isInAsyncCall = false;
  callAPIToUpdateCategoryItems(int menuCategoryId, List<MenuItem> menuItems,
      BuildContext context) async {
    setState(() {
      _isInAsyncCall = true;
    });

    var hlp = Helper();
    var data = Map<String, dynamic>();
    data['menuCategoryId'] = menuCategoryId;
    data['menuItemIds'] = menuItems.map((e) => e.menuItemId).toList();
    var res = await hlp.postData("api/menu/addItemToCategory", data,
        context: context);

    if (res.isSuccess) {
      await Provider.of<CurrentMenuProvider>(context, listen: false)
          .getMenuFromAPI(
              context,
              Provider.of<CurrentStoresProvider>(context, listen: false)
                  .getSelectedStore
                  .storeId);
      setState(() {
        _isInAsyncCall = false;
      });
      Navigator.pop(context);
    } else {
      hlp.showToastError(
          "${AppLocalizationHelper.of(context).translate('UpdateItemFailedAlert')}");
    }
  }

  @override
  void initState() {
    List<MenuItem> allItems = List<MenuItem>.from(
        Provider.of<CurrentMenuProvider>(context, listen: false)
            .getStoreMenu
            .menuItems);

    currentSelectedItems = List<MenuItem>.from(
        Provider.of<CurrentMenuProvider>(context, listen: false)
            .getSelectedMenuItems);

    if (allItems.length > 0 && (currentSelectedItems?.length ?? 0) > 0) {
      allItems.removeWhere((element) => currentSelectedItems.contains(element));
    }

    selectedCategory = Provider.of<CurrentMenuProvider>(context, listen: false)
        .getSelectedCategory;

    unSelectedItems = allItems;
    unSelectedItems.forEach((element) {
      element.isSelectedForCategory = false;
    });

    currentSelectedItems.forEach((element) {
      element.isSelectedForCategory = true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentMenuProvider>(
        builder: (ctx, p, w) {
        return ModalProgressHUD(
          inAsyncCall: _isInAsyncCall,
          opacity: 0.5,
          progressIndicator: CircularProgressIndicator(),
          child: Scaffold(
              appBar: CustomAppBar.getAppBar(
                  "${selectedCategory.menuCategoryName}", true,
                  showLogo: false,
                  context: context,
                  rightButtonIcon: InkWell(
                    child: Text(
                      AppLocalizationHelper.of(context).translate('Save'),
                      style: GoogleFonts.lato(
                          color: Colors.black,
                          fontSize: ScreenHelper.isLandScape(context)
                              ? SizeHelper.textMultiplier * 2
                              : SizeHelper.textMultiplier * 2),
                    ),
                    onTap: () async {
                      await callAPIToUpdateCategoryItems(
                          p.getSelectedCategory.menuCategoryId,
                          p.getSelectedMenuItems,
                          context);
                      p.resetSearchItemsAdded();
                      p.resetSearchItemsCheckToAdd();
                    },
                  )),
              body: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VEmptyView(20),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: SizeHelper.heightMultiplier * 1,
                          horizontal: SizeHelper.widthMultiplier * 4.7),
                      child: TextFieldRow(
                        isReadOnly: false,
                        context: context,
                        textController: searchBarController,
                        icon: Icon(Icons.search),
                        isMandate: false,
                        focusNode: searchBarFocus,
                        suffixIcon: IconButton(
                          onPressed: () {
                            searchBarController.clear();
                            p.resetSearchItemsAdded();
                            p.resetSearchItemsCheckToAdd();
                          },
                          icon: Icon(Icons.clear),
                        ),
                        hintText:
                        "itemsSearch",
                        onChanged: (v) {
                          if (v != null && v != "") {
                            p.searchItemsCheckToAdd(v);
                            p.searchItemsAdded(v);
                          }else {
                            p.resetSearchItemsAdded();
                            p.resetSearchItemsCheckToAdd();
                          }
                        },
                      ).textFieldRow(),
                    ),
                    VEmptyView(20),
                    _addedSelectionList(p.getSearchedItemsAdded,p.getSelectedMenuItems),
                    _toBeAddedSelectionList(p.getSearchedItemsCheckToAdd,p.getSelectedMenuItems, p.getStoreMenu.menuItems),
                    _newItemButton()
                  ],
                ),
              )),
        );
      }
    );
  }

  _addedSelectionList(searchedItemsAdded,selectedMenuItems) {
    if(searchedItemsAdded==null){
      searchedItemsAdded = selectedMenuItems;
    }
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.all(ScreenUtil().setSp(20)),
          child: Text(
            AppLocalizationHelper.of(context).translate('Added'),
            style: GoogleFonts.lato(
              fontSize: ScreenHelper.isLandScape(context)
                  ? SizeHelper.textMultiplier * 2
                  : SizeHelper.textMultiplier * 2.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        ListView.builder(
            controller: scrollController,
            shrinkWrap: true,
            itemCount: searchedItemsAdded.length,
            itemBuilder: (ctx, index) {
              MenuItem item = searchedItemsAdded[index];

              return AddItemsToCategoryListTile(
                menuItem: item,
                toggleCheckCallBack: _toggleCheckCallBack,
              );
            })
      ],
    );
  }

  _toggleCheckCallBack(bool v, MenuItem item,List<MenuItem> selectedMenuItems,List<MenuItem> unselectedMenuItems) {
    setState(() {
      if (v && !item.isSelectedForCategory) {
        if(searchBarController.text!="") {
          Provider.of<CurrentMenuProvider>(context, listen: false)
              .addToSearchItemsAdded(item);
          Provider.of<CurrentMenuProvider>(context, listen: false)
              .removeFromSearchItemsCheckToAdd(item);
          selectedMenuItems.add(item);
          unselectedMenuItems.remove(item);
        }else {
          // Provider.of<CurrentMenuProvider>(context, listen: false).removeFromUnSelectedItems(item);

          selectedMenuItems.add(item);
          unselectedMenuItems.remove(item);
        }
      } else if (!v && item.isSelectedForCategory) {
        if(searchBarController.text!="") {
          Provider.of<CurrentMenuProvider>(context, listen: false)
              .removeFromSearchItemsAdded(item);
          Provider.of<CurrentMenuProvider>(context, listen: false)
              .addToSearchItemsCheckToAdd(item);
          selectedMenuItems.remove(item);
          unselectedMenuItems.add(item);
        }else {
          // Provider.of<CurrentMenuProvider>(context, listen: false).addToUnSelectedItems(item);
          selectedMenuItems.remove(item);
          unselectedMenuItems.add(item);
        }
      }
      item.isSelectedForCategory = v;
    });
  }

  _toBeAddedSelectionList(List<MenuItem> searchedItemsCheckToAdd,List<MenuItem> selectedMenuItems,List<MenuItem> unselectedMenuItems) {
    unselectedMenuItems.removeWhere((element) => selectedMenuItems.contains(element));
    if(searchedItemsCheckToAdd==null){
      searchedItemsCheckToAdd = unselectedMenuItems;
    }
    return Column(
      children: [
        Divider(
          thickness: 2,
        ),
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.all(ScreenUtil().setSp(20)),
          child: Text(
            AppLocalizationHelper.of(context).translate('CheckToAdd'),
            style: GoogleFonts.lato(
              fontSize: ScreenHelper.isLandScape(context)
                  ? SizeHelper.textMultiplier * 2
                  : SizeHelper.textMultiplier * 2,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        ListView.builder(
            controller: scrollController,
            shrinkWrap: true,
            itemCount: searchedItemsCheckToAdd.length,
            itemBuilder: (ctx, index) {
              MenuItem item = searchedItemsCheckToAdd[index];

              return AddItemsToCategoryListTile(
                menuItem: item,
                toggleCheckCallBack: _toggleCheckCallBack,
              );
            })
      ],
    );
  }

  _newItemButton() {
    return Column(
      children: [
        Divider(
          thickness: 2,
        ),
        VEmptyView(20),
        Container(
          height: SizeHelper.isMobilePortrait
              ? 4.5 * SizeHelper.heightMultiplier
              : 5 * SizeHelper.widthMultiplier,
          child: RoundedVplusLongButton(
            text: AppLocalizationHelper.of(context).translate('NewItem'),
            callBack: () async {
              //TODO may need to get the new added Item to add to unselected list and setState
              var menuItem = await pushNewScreen(context,
                  screen: NewItem(),
                  pageTransitionAnimation: PageTransitionAnimation.fade);

              setState(() {
                unSelectedItems.add(MenuItem?.fromJson(menuItem));
              });
            },
          ),
        ),
        if (ScreenHelper.isLandScape(context)) VEmptyView(20),
      ],
    );
  }
}

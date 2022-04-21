import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/models/Order.dart';
import 'package:vplus_merchant_app/models/menuAddOn.dart';
import 'package:vplus_merchant_app/models/menuCategory.dart';
import 'package:vplus_merchant_app/models/menuItem.dart';
import 'package:vplus_merchant_app/models/storeMenu.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/providers/orderlist_provider.dart';

class CurrentMenuProvider with ChangeNotifier {
  List<MenuItem> _searchedItems;
  List<MenuItem> _searchedItemsAdded;
  List<MenuItem> _searchedItemsCheckToAdd;

  Future getMenuFromAPI(BuildContext context, int storeId) async {
    var hlp = Helper();
    // get latest menu
    var response =
        await hlp.getData("api/Menu/$storeId", context: context, hasAuth: true);

    print("fetched menu data");
    if (response.isSuccess == false) {
      // init store menu for first login
      var initResponse = await hlp.postData("api/Menu/$storeId", null,
          context: context, hasAuth: true);
      response = initResponse;
    }
    if (response.isSuccess && response.data != null) {
      _selectedStoreId = storeId;
      _currentMenu = StoreMenu.fromJson(response.data);
      if (_currentMenu.menuCategories.isEmpty) {
        _selectedCategoryId = 0;
      } else {
        _selectedCategoryId ??=
            _currentMenu.menuCategories.first.menuCategoryId;
        // update category after switch store
        if ((_currentMenu.menuCategories.singleWhere(
                (category) => category.menuCategoryId == _selectedCategoryId,
                orElse: () => null)) ==
            null) {
          _selectedCategoryId =
              _currentMenu.menuCategories.first.menuCategoryId;
        }
      }
      notifyListeners();
    } else {
      hlp.showToastError(AppLocalizationHelper.of(context).translate(
          '${AppLocalizationHelper.of(context).translate('FailedToGetMenuInfoNote')}'));
      return Future.error(null);
    }
  }


  Future setItemIsPopular(BuildContext context, int menuItemId,bool isPopular) async {
    var hlp = Helper();
    var response =
    await hlp.putData("api/Menu/items/$menuItemId/popular?isPopular=$isPopular",null,context: context, hasAuth: true);
    if(response.isSuccess){
      notifyListeners();
    }else{
      hlp.showToastSuccess("Fail to set popular");
    }

  }

  Future addMenuCategory(
      BuildContext context, String menuCategoryName, String subtitle) async {
    var hlp = Helper();
    Map<String, dynamic> data = {
      "menuCategoryName": menuCategoryName,
      "description": "", // currently not passing the desc
      'subtitle': subtitle,
    };
    var response = await hlp.postData(
        "api/Menu/$_selectedStoreId/category", data,
        context: context, hasAuth: true);

    if (response.isSuccess && response.data != null) {
      hlp.showToastSuccess(AppLocalizationHelper.of(context)
          .translate('SuccessCreateCategoryNote'));

      await getMenuFromAPI(
          context,
          Provider.of<CurrentStoresProvider>(context, listen: false)
              .getSelectedStore
              .storeId);
      return true;
    } else {
      hlp.showToastError(AppLocalizationHelper.of(context)
          .translate('FailedToCreateCateoryInfoNote'));
      return false;
    }
  }

  Future updateMenuCategory(
      BuildContext context, String menuCategoryName, String subtitle) async {
    var hlp = Helper();
    Map<String, dynamic> data = {
      "menuCategoryName": menuCategoryName,
      "subtitle": subtitle,
      // "description": "", // currently not passing the desc
    };
    var response = await hlp.putData(
        "api/Menu/$_selectedCategoryId/category", data,
        context: context, hasAuth: true);

    if (response.isSuccess) {
      // update name locally for better performance

      await getMenuFromAPI(
          context,
          Provider.of<CurrentStoresProvider>(context, listen: false)
              .getSelectedStore
              .storeId);
      hlp.showToastSuccess(AppLocalizationHelper.of(context)
          .translate('SuccessUpdateCateInfoNote'));

      return true;
    } else {
      hlp.showToastSuccess(AppLocalizationHelper.of(context)
          .translate('FailedUpdateCateInfoNote'));

      return false;
    }
  }

  Future deleteMenuCategory(BuildContext context) async {
    var hlp = Helper();

    var response = await hlp.deleteData(
        "api/Menu/$_selectedCategoryId/category",
        context: context,
        hasAuth: true);

    if (response.isSuccess) {
      hlp.showToastSuccess(AppLocalizationHelper.of(context)
          .translate('SuccessDeleteCateInfoNote'));

      await getMenuFromAPI(
          context,
          Provider.of<CurrentStoresProvider>(context, listen: false)
              .getSelectedStore
              .storeId);
      return true;
    } else {
      hlp.showToastSuccess(AppLocalizationHelper.of(context)
          .translate('FailedDeleteCateInfoNote'));
      return false;
    }
  }

  Future sortMenuCategory(
      BuildContext context, int menuCategoryId, int newIndex) async {
    var hlp = Helper();
    Map<String, dynamic> data = {
      "MenuCategoryId": menuCategoryId,
      "NewIndex": newIndex,
    };

    var response = await hlp.putData("api/Menu/sortCategories", data,
        context: context, hasAuth: true);

    if (response.isSuccess) {
      // hlp.showToastSuccess("Category reordered.");
    } else {
      hlp.showToastSuccess(AppLocalizationHelper.of(context)
          .translate('FailedReOrderCateInfoNote'));
    }

    await getMenuFromAPI(
        context,
        Provider.of<CurrentStoresProvider>(context, listen: false)
            .getSelectedStore
            .storeId);
  }

  setCurrentCategoryId(int categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  int _selectedStoreId;
  StoreMenu _currentMenu;
  int _selectedCategoryId;
  bool hasShownReadOnlyDialog = false;

  bool get getHasShownReadOnlyDialog => hasShownReadOnlyDialog;
  void setShownReadOnlyDialog() {
    hasShownReadOnlyDialog = true;
  }

  void resetShownReadOnlyDialog() {
    hasShownReadOnlyDialog = false;
  }

  int get getStoreMenuId => _currentMenu.storeMenuId;
  StoreMenu get getStoreMenu => _currentMenu;
  int get getSelectedCategoryId => _selectedCategoryId;
  List<MenuItem> get getSelectedMenuItems => (_currentMenu.menuCategories ==
              null ||
          _currentMenu.menuCategories.isEmpty)
      ? new List<MenuItem>()
      : _currentMenu.menuCategories
          .firstWhere(
              (catList) => catList?.menuCategoryId == _selectedCategoryId)
          ?.menuItems;

  MenuCategory get getSelectedCategory =>
      (_currentMenu?.menuCategories == null ||
                  (_currentMenu?.menuCategories?.isEmpty) ??
              true)
          ? new MenuCategory()
          : _currentMenu.menuCategories.firstWhere(
              (catList) => catList?.menuCategoryId == _selectedCategoryId);

  Future<bool> setSoldoutInAllItemMenu(
      BuildContext context, int itemID, bool value) async {
    var hlp = Helper();
    Map<String, dynamic> data = {
      "isSoldOut": value,
    };
    var response = await hlp.putData(
        "api/Menu/items/$itemID/avaliability", data,
        context: context, hasAuth: true);

    if (response.isSuccess) {
      await getMenuFromAPI(context, _selectedStoreId);
      notifyListeners();
      return true;
    } else {
      hlp.showToastSuccess(AppLocalizationHelper.of(context)
          .translate('FailedUpdateSoldOutItemNote'));

      return false;
    }
  }

  Future<dynamic> addNewItem(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    var hlp = Helper();
    int storeMenuID = _currentMenu.storeMenuId;
    var response = await hlp.postData("api/Menu/items/$storeMenuID", data,
        context: context, hasAuth: true);

    if (response.isSuccess && response.data != null) {
      await getMenuFromAPI(context, _selectedStoreId);

      notifyListeners();
      return response.data;
    } else {
      hlp.showToastError(AppLocalizationHelper.of(context)
          .translate("FailedToCreateItemNote"));
      return null;
    }
  }

  Future<bool> deleteItem(
    BuildContext context,
    int menuItemID,
  ) async {
    var hlp = Helper();
    int storeMenuID = _currentMenu.storeMenuId;
    var response = await hlp.deleteData("api/Menu/items/$menuItemID",
        context: context, hasAuth: true);

    if (response.isSuccess) {
      await getMenuFromAPI(context, _selectedStoreId);

      notifyListeners();
      return true;
    } else {
      hlp.showToastError(AppLocalizationHelper.of(context)
          .translate("FailedToDeleteItemNote"));
      return false;
    }
  }

  Future<bool> updateItem(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    var hlp = Helper();
    String menuItemID = data["menuItemId"].toString();
    var response = await hlp.putData("api/Menu/items/$menuItemID", data,
        context: context, hasAuth: true);

    if (response.isSuccess) {
      await getMenuFromAPI(context, _selectedStoreId);
      notifyListeners();
      return true;
    } else {
      hlp.showToastError(AppLocalizationHelper.of(context)
          .translate("FailedToUpdateItemNote"));
      return false;
    }
  }

  clearMenu() {
    _selectedStoreId = null;
    _currentMenu = null;
    _selectedCategoryId = null;
  }

  Future<bool> sortItem(BuildContext context, int menuCategoryId,
      int menuItemId, int newIndex) async {
    var hlp = Helper();
    Map<String, dynamic> data = {
      "menuCategoryId": menuCategoryId,
      "NewIndex": newIndex,
    };

    var response = await hlp.putData("api/Menu/items/${menuItemId}/sort", data,
        context: context, hasAuth: true);

    if (response.isSuccess) {
      // hlp.showToastSuccess("item reordered.");
      await getMenuFromAPI(context, _selectedStoreId);

      return true;
    } else {
      hlp.showToastError(
          AppLocalizationHelper.of(context).translate("FailedReOrderItemNote"));
      return false;
    }
  }

  int _selectedMenuItemID;
  MenuItem get getSelectedItemForItemMenu => _currentMenu.menuItems
      .firstWhere((e) => _selectedMenuItemID == e.menuItemId);
  void setSelectedMenuItemID(int selectedMenuItemID) {
    _selectedMenuItemID = selectedMenuItemID;
    notifyListeners();
  }

  List<MenuItem> get getSearchedItems => _searchedItems;
  void setSearchItems(List<MenuItem> searchedItems) {
    _searchedItems = searchedItems;
    notifyListeners();
  }

  void resetSearchItems() {
    _searchedItems = null;
    notifyListeners();
  }

  void addToSearchItems(MenuItem item) {
    _searchedItems.add(item);
    notifyListeners();
  }
  void removeFromSearchItems(MenuItem item) {
    _searchedItems.remove(item);
    notifyListeners();
  }

  void addToSearchItemsAdded(MenuItem item) {
    _searchedItemsAdded.add(item);
    notifyListeners();
  }

  void removeFromSearchItemsAdded(MenuItem item) {
    _searchedItemsAdded.remove(item);
    notifyListeners();
  }

  void addToSearchItemsCheckToAdd(MenuItem item) {
    _searchedItemsCheckToAdd.add(item);
    notifyListeners();
  }

  void removeFromSearchItemsCheckToAdd(MenuItem item) {
    _searchedItemsCheckToAdd.remove(item);
    notifyListeners();
  }

  void resetSearchItemsAdded() {
    _searchedItemsAdded = null;
    notifyListeners();
  }

  void resetSearchItemsCheckToAdd() {
    _searchedItemsCheckToAdd = null;
    notifyListeners();
  }

  List<MenuAddOn> _selectedAddOns;
  List<MenuAddOn> get getSelectedAddOns => _selectedAddOns;
  void setSelectedAddons(List<MenuAddOn> selectedAddOns) {
    _selectedAddOns = selectedAddOns;
    notifyListeners();
  }

  void removeSelectedAddons() {
    _selectedAddOns = null;
  }

  searchItems(String keyword) {
    _searchedItems = _currentMenu.menuItems
        .where((element) => element.menuItemName
                .toLowerCase()
                .replaceAll(new RegExp(r"\s+"), "")
                .startsWith(
                keyword.toLowerCase().replaceAll(new RegExp(r"\s+"), '')))
        .toList();
    var _searchedItemsCh = _currentMenu.menuItems
        .where((element) =>
    element?.subtitle?.contains(keyword) ??
        false)
        .toList();
    _searchedItems.addAll(_searchedItemsCh);
    notifyListeners();
  }

  List<MenuItem> get getSearchedItemsAdded => _searchedItemsAdded;
  searchItemsAdded(String keyword) {
    _searchedItemsAdded = this
        .getSelectedMenuItems
        .where((element) => element.menuItemName
            .toLowerCase()
            .replaceAll(new RegExp(r"\s+"), "")
            .startsWith(
                keyword.toLowerCase().replaceAll(new RegExp(r"\s+"), '')))
        .toList();
    var _searchedItemsCh = _currentMenu.menuItems
        .where((element) =>
    element?.subtitle?.contains(keyword) ??
        false)
        .toList();
    _searchedItemsAdded.addAll(_searchedItemsCh);
    notifyListeners();
  }

  List<MenuItem> get getSearchedItemsCheckToAdd => _searchedItemsCheckToAdd;
  searchItemsCheckToAdd(String keyword) {
    _searchedItemsCheckToAdd = _currentMenu.menuItems
        .where((element) => element.menuItemName
            .toLowerCase()
            .replaceAll(new RegExp(r"\s+"), "")
            .startsWith(
                keyword.toLowerCase().replaceAll(new RegExp(r"\s+"), '')))
        .toList();
    var _searchedItemsCh = _currentMenu.menuItems
        .where((element) =>
    element?.subtitle?.contains(keyword) ??
        false)
        .toList();
    _searchedItemsCheckToAdd.addAll(_searchedItemsCh);
    notifyListeners();
  }

  Future<bool> removeMenuItemFromCategory(
      BuildContext context, int menuItemId, int menuCategoryId) async {
    var hlp = Helper();
    Map<String, dynamic> data = {
      "menuItemId": menuItemId,
      "menuCategoryId": menuCategoryId,
    };

    var response = await hlp.putData(
        "api/Menu/menuCategory/menuItems/remove", data,
        context: context, hasAuth: true);

    if (response.isSuccess) {
      hlp.showToastSuccess("removed item from category.");
      await getMenuFromAPI(context, _selectedStoreId);

      return true;
    } else {
      hlp.showToastError(AppLocalizationHelper.of(context)
          .translate("FailedToRemoveItemNote"));
      return false;
    }
  }

  Future<List<MenuAddOn>> getMenuAddOnsByMenuitemId(
      BuildContext context, int menuItemId) async {
    var hlp = Helper();
    List<MenuAddOn> menuAddOns;
    var response = await hlp.getData("api/Menu/items/${menuItemId}/addons",
        context: context, hasAuth: true);

    if (response.isSuccess) {
      // hlp.showToastSuccess("menuaddon updated.");
      menuAddOns = new List<MenuAddOn>.from(
          response.data.map((e) => MenuAddOn.fromJson(e)));
      return menuAddOns;
    } else {
      hlp.showToastError(AppLocalizationHelper.of(context)
          .translate("FailedToGetMenuAddonNote"));
      return new List<MenuAddOn>();
    }
  }
}

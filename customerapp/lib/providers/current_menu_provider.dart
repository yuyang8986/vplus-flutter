import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/models/menuAddOn.dart';
import 'package:vplus/models/menuCategory.dart';
import 'package:vplus/models/menuItem.dart';
import 'package:vplus/models/storeMenu.dart';

class CurrentMenuProvider with ChangeNotifier {
  Future<StoreMenu> getMenuFromAPI(BuildContext context, int storeId) async {
    var hlp = Helper();
    // get latest menu
    var response =
        await hlp.getData("api/Menu/$storeId", context: context, hasAuth: true);
    print("menu fetching result:" + response.isSuccess.toString());

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
      return _currentMenu;
      //notifyListeners();
    } else {
      hlp.showToastError("Did not get the menu information, please try again.");
      return null;
      // return Future.error(null);
    }
  }

  setCurrentCategoryId(int categoryId) {
    _selectedCategoryId = categoryId;
    // notifyListeners();
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
      hlp.showToastError(
          "Failed to update the sold out in the menu item, please try again.");
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
      hlp.showToastError("Failed to create the item, please try again.");
      return null;
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
      hlp.showToastError("Failed to update the item, please try again.");
      return false;
    }
  }

  clearMenu() {
    _selectedStoreId = null;
    _currentMenu = null;
    _selectedCategoryId = null;
  }

  Future<bool> sortItem(
      BuildContext context, int menuItemId, int newIndex) async {
    var hlp = Helper();
    Map<String, dynamic> data = {
      "NewIndex": newIndex,
    };

    var response = await hlp.putData("api/Menu/items/${menuItemId}/sort", data,
        context: context, hasAuth: true);

    if (response.isSuccess) {
      // hlp.showToastSuccess("item reordered.");
      await getMenuFromAPI(context, _selectedStoreId);

      return true;
    } else {
      hlp.showToastError("Failed to reorder the item, please try again.");
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

  List<MenuAddOn> _selectedAddOns;
  List<MenuAddOn> get getSelectedAddOns => _selectedAddOns;
  void setSelectedAddons(List<MenuAddOn> selectedAddOns) {
    _selectedAddOns = selectedAddOns;
    notifyListeners();
  }

  void removeSelectedAddons() {
    _selectedAddOns = null;
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
      hlp.showToastError(
          "Failed to remove item from category, please try again.");
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
      hlp.showToastError("Failed to get menuAddon, please try again.");
      return new List<MenuAddOn>();
    }
  }
}

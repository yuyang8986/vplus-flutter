import 'package:flutter/cupertino.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/models/menuItem.dart';
import 'package:vplus/models/storeMenu.dart';

class GroceriesItemProvider extends ChangeNotifier {
  StoreMenu _currentMenu;
  List<MenuItem> searchedItems;

  Future<StoreMenu> getGroceriesItemListByCoordinates(
      BuildContext context, String deviceCoordinates) async {
    var helper = Helper();
    var response = await helper.getData(
        "api/menu/groceries/user?deviceCoordinates=$deviceCoordinates",
        context: context,
        hasAuth: false);
    if (response.isSuccess) {
      if (response.data == null) {
        _currentMenu = null;
        notifyListeners();
        return null;
      }
      _currentMenu = StoreMenu.fromJson(response.data);
      notifyListeners();
    } else {
      helper.showToastError('Unable to get items, please try again');
    }
    return _currentMenu;
  }

  searchItems(String keyword) {
    searchedItems = _currentMenu.menuItems
        .where((element) =>
            element.menuItemName
                .toLowerCase()
                .replaceAll(new RegExp(r"\s+"), "")
                .startsWith(
                    keyword.toLowerCase().replaceAll(new RegExp(r"\s+"), '')) ||
            element.subtitle.contains(keyword))
        .toList();
    notifyListeners();
  }

  setItemPrice(double newPricePercentage) {
    _currentMenu.menuItems.forEach((item) {
      item.price *= (1 + newPricePercentage);
      item.ifChanged = true;
    });
    _currentMenu.menuCategories.forEach((category) {
      category.menuItems.forEach((item) {
        item.price *= (1 + newPricePercentage);
        item.ifChanged = true;
      });
    });
    notifyListeners();
  }

  resetSearchResult() {
    searchedItems = [];
    notifyListeners();
  }

  StoreMenu get getStoreMenu => _currentMenu;
}

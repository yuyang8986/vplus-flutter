import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/date_time_helper.dart';
import 'package:vplus_merchant_app/helpers/fcmHelper.dart';
import 'package:vplus_merchant_app/models/StoreKitchen.dart';
import 'package:vplus_merchant_app/models/http/http_response.dart';
import 'package:vplus_merchant_app/models/store.dart';
import 'package:vplus_merchant_app/providers/orderlist_provider.dart';

import 'currentuser_provider.dart';

class CurrentStoresProvider with ChangeNotifier {
  getStoreFromAPI(BuildContext context) async {
    // get store list by org id
    var hlp = Helper();
    var orgId = Provider.of<CurrentUserProvider>(context, listen: false)
        .getloggedInUser
        .organizationId
        .toString();
    var response = await hlp.getData("api/stores/organizations/$orgId",
        context: context, hasAuth: true);

    _currentStores =
        List.from(response.data).map((e) => Store.fromJson(e)).toList();

    notifyListeners();
  }

  getSingleStoreFromAPI(BuildContext context, int storeId) async {
    // get single store by store id
    var hlp = Helper();

    var response = await hlp.getData("api/stores/$storeId",
        context: context, hasAuth: true);

    _currentStores[_currentStores.indexWhere((s) => s.storeId == storeId)] =
        Store.fromJson(response.data);

    notifyListeners();
  }

  List<Store> _currentStores;
  int selectedStoreID;
  int storeMenuId;

  List<Store> get getCurrentStores => _currentStores;
  Store get getSelectedStore => _currentStores[
      _currentStores.indexWhere((e) => e.storeId == selectedStoreID)];

  setCurrentStores(List<Store> stores) {
    _currentStores = stores;
    notifyListeners();
  }

  setSelectedStore(int storeId) {
    selectedStoreID = storeId;
    notifyListeners();
  }

  get getSelectedStoreId => selectedStoreID;

  setUpdatedStore(Store store) {
    _currentStores[
        _currentStores.indexWhere((e) => e.storeId == store.storeId)] = store;
    notifyListeners();
  }

  Future<Store> getSingleStoreById(BuildContext context, int storeId) async {
    var hlp = Helper();
    var response = await hlp.getData("api/stores/$storeId",
        context: context, hasAuth: true);
    if (response.isSuccess) {
      Store store = Store.fromJson(response.data);
      //storeMenuId = store.storeMenus.storeMenuId;
      return store;
    } else {
      return new Store();
    }
  }

  Store getStore(BuildContext context) {
    /// get store for both Admin and staff roles
    Store store =
        Provider.of<CurrentUserProvider>(context, listen: false).isAdmin()
            ? Provider.of<CurrentStoresProvider>(context, listen: false)
                .getSelectedStore
            : Provider.of<CurrentUserProvider>(context, listen: false)
                .getloggedInUser
                .store;
    return store;
  }

  int getStoreId(BuildContext context) {
    /// get store id for both Admin and staff roles
    int storeId =
        Provider.of<CurrentUserProvider>(context, listen: false).isAdmin()
            ? Provider.of<CurrentStoresProvider>(context, listen: false)
                .getSelectedStore
                .storeId
            : Provider.of<CurrentUserProvider>(context, listen: false)
                .getloggedInUser
                .storeId;
    return storeId;
  }

  // getStoreMenuId(BuildContext context) {
  //   /// get store menu id for both Admin and staff roles
  //   Store store = getStore(context);
  //   // if (Provider.of<CurrentUserProvider>(context, listen: false).isAdmin()) {
  //   //   if (storeMenuId != null) {
  //   //     return storeMenuId;
  //   //   } else {
  //   //     // for admin, need to get store infor from api first
  //   //     getSingleStoreById(context, store.storeId)
  //   //         .then((value) => store = value);
  //   //     storeMenuId = store.storeMenus.storeMenuId;
  //   //   }
  //   // } else {
  //   //   return store.storeMenus.storeMenuId;
  //   //   ;
  //   // }
  //   return store.storeMenus.storeMenuId;
  // }

  Future<void> removeStoreDevice(BuildContext context) async {
    Store store = getStore(context);
    var helper = Helper();
    String token = FCMHelper.token;
    var response = await helper.deleteData(
        'api/StoreDevice/remove/${store.storeId}?fcmToken=${token}',
        context: context,
        hasAuth: true);
    if (response.isSuccess) {
      print('Remove Store Device Success');
    }
  }

  List<StoreKitchen> get getSelectedStoreKitchens {
    Store currentStore = getSelectedStore;
    return currentStore.storeKitchens;
  }

  bool get hasKitchenInStore {
    List<StoreKitchen> availableKitchens = getSelectedStoreKitchens;
    return (availableKitchens == null || availableKitchens.isEmpty)
        ? false
        : true;
  }

  Future<bool> setOpenTime(
      BuildContext context, TimeOfDay openTime, TimeOfDay closeTime) async {
    var helper = Helper();
    Map<String, dynamic> data = {
      "storeOpenTime": DateTimeHelper.parseDateTimeToCsharpFormat(
          DateTime(1970, 1, 1, openTime.hour, openTime.minute).toUtc()),
      "storeCloseTime": DateTimeHelper.parseDateTimeToCsharpFormat(
          DateTime(1970, 1, 1, closeTime.hour, closeTime.minute).toUtc())
    };
    var response = await helper.putData(
        'api/stores/$selectedStoreID/setOpenTime', data,
        context: context, hasAuth: true);
    if (response.isSuccess) {
      await getSingleStoreFromAPI(context, selectedStoreID);
      helper.showToastSuccess("Store open time updated.");
    }
    return response.isSuccess;
  }
}

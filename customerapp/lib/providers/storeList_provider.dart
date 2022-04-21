import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/helper/locationHelper.dart';
import 'package:vplus/models/store.dart';
import 'package:geocoder/geocoder.dart';
import 'package:vplus/models/storeBusinessType.dart';

import 'package:vplus/providers/currentuser_provider.dart';

class StoreListProvider with ChangeNotifier {
  String filterString;

  List<String> supportFilter = ['Nearby', 'Category'];

  List<Map<String, Object>> storeListDistanceMap = [];

  List<StoreBusinessType> storeBusinessType;

  List<Store> keywordSearchResult;

  List<Store> storeList;

  List<Store> sortedByCuisineList = new List<Store>();

  StoreBusinessType _selectedStoreBusinessType;

  bool hasNextPage;

  get getStoreList => storeList;
  set setStoreList(List<Store> newStoreList) {
    storeList = newStoreList;
    notifyListeners();
  }

  Future<List<StoreBusinessType>> getAllBusinessTypes(
      BuildContext context) async {
    var helper = Helper();
    var response = await helper.getData(
        "api/StoreBusinessCatType/getAllCatTypes",
        context: context,
        hasAuth: true);
    if (response.isSuccess && response.data != null) {
      List<StoreBusinessType> result = [];

      for (int i = 0; i < response.data['storeBusinessCatTypes'].length; i++) {
        StoreBusinessType storeBusinessType = StoreBusinessType.fromJson(
            response.data['storeBusinessCatTypes'][i]);
        if (storeBusinessType.catLevel == 2) {
          result.add(storeBusinessType);
        }
      }
      this.storeBusinessType = result;
      return result;
    } else {
      helper.showToastError('Unable to load business types, please try again');
      return [];
    }
  }

  Future<List<Store>> getStoreListFromAPI(
      BuildContext context,
      List<int> businessCatTypes,
      int pageNumber,
      bool sortByDistance,
      Coordinates currentLocation,
      {bool isReFresh = false}) async {
    // var locationHelper = LocationHelper();

    if (isReFresh) {
      storeList = [];
    } else {
      storeList ??= [];
    }

    var helper = Helper();
    var data = {
      "storeBusinessCatTypeIds": businessCatTypes,
      "deviceCoordinates":
          "${currentLocation.latitude},${currentLocation.longitude}"
    };
    var response = await helper.postData(
        "api/stores/filter?ByDistance=$sortByDistance&PageNumber=$pageNumber",
        data,
        context: context,
        hasAuth: true);

    if (response.isSuccess && response.data != null) {
      Map<String, dynamic> header = helper.getResponseHeaderXPag();
      this.hasNextPage = header["HasNext"] as bool;
      for (int i = 0; i < response.data.length; i++) {
        Store store = Store.fromJson(response.data[i]);

        if (_selectedStoreBusinessType != null) {
          sortedByCuisineList.add(store);
        } else {
          storeList.add(store);
        }
      }
    } else {
      helper.showToastError('Unable to load nearby stores, please try again');
    }
    notifyListeners();

    return storeList;
  }

  Future<bool> searchByKeyword(BuildContext context, String keyword) async {
    var helper = Helper();

    var response = await helper.getData("api/stores/search/$keyword",
        context: context, hasAuth: true);

    if (response.isSuccess) {
      keywordSearchResult =
          List.from(response.data).map((e) => Store.fromJson(e)).toList();
      notifyListeners();
    } else {
      helper.showToastError('Unable to search stores, please try again');
    }
    return response.isSuccess;
  }

  void setDefaultFilter() {
    this.filterString = "Shortest Distance";
  }

  void setFilterString(String filter) {
    this.filterString = filter;
  }

  void setHasNextPage(bool hasNext) {
    this.hasNextPage = hasNext;
  }

  bool get getHasNextPage => this.hasNextPage;

  String getFilterString() {
    return this.filterString;
  }

  List<String> getSupportFilter() {
    return this.supportFilter;
  }

  List<StoreBusinessType> get getStoreBusinessType => this.storeBusinessType;

  List<Store> get getSearchResults => keywordSearchResult;

  void resetSearchResults() {
    keywordSearchResult = [];
    notifyListeners();
  }

  void setSelectedCuisine(StoreBusinessType cuisineType) {
    _selectedStoreBusinessType = cuisineType;
    notifyListeners();
  }

  void setSortedByCuisineTypeList(List<Store> list) {
    sortedByCuisineList = list;
    notifyListeners();
  }
}

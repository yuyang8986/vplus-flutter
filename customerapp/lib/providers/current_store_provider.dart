import 'package:flutter/material.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/models/fees.dart';
import 'package:vplus/models/store.dart';

class CurrentStoreProvider with ChangeNotifier {
  Store selectedStore;

  Store get getCurrentStore => selectedStore;

  set setCurrentStore(Store newStore) {
    selectedStore = newStore;
    notifyListeners();
  }

  Future<bool> getSingleStoreById(BuildContext context, int storeId) async {
    var hlp = Helper();
    var response = await hlp.getData("api/stores/$storeId",
        context: context, hasAuth: false);
    if (response.isSuccess) {
      selectedStore = Store.fromJson(response.data);
      notifyListeners();
    }
    return response.isSuccess;
  }
}
// class CurrentStoresProvider with ChangeNotifier {
//   getStoreFromAPI(BuildContext context) async {
//     var hlp = Helper();
//     // var orgId = Provider.of<CurrentUserProvider>(context, listen: false)
//     //     .getloggedInUser
//     //     .organizationId
//     //     .toString();
//     // var response = await hlp.getData("api/stores/organizations/$orgId",
//     //     context: context, hasAuth: true);

//     // _currentStores =
//     //     List.from(response.data).map((e) => Store.fromJson(e)).toList();

//     notifyListeners();
//   }

//   List<Store> _currentStores;
//   int selectedStoreID;
//   int storeMenuId;

//   List<Store> get getCurrentStores => _currentStores;
//   Store get getSelectedStore => _currentStores[
//       _currentStores.indexWhere((e) => e.storeId == selectedStoreID)];

//   setCurrentStores(List<Store> stores) {
//     _currentStores = stores;
//     notifyListeners();
//   }

//   setSelectedStore(int storeId) {
//     selectedStoreID = storeId;
//     notifyListeners();
//   }

//   get getSelectedStoreId => selectedStoreID;

//   setUpdatedStore(Store store) {
//     _currentStores[
//         _currentStores.indexWhere((e) => e.storeId == store.storeId)] = store;
//     notifyListeners();
//   }

//   Future<Store> getSingleStoreById(BuildContext context, int storeId) async {
//     var hlp = Helper();
//     var response = await hlp.getData("api/stores/$storeId",
//         context: context, hasAuth: true);
//     if (response.isSuccess) {
//       Store store = Store.fromJson(response.data);
//       //storeMenuId = store.storeMenus.storeMenuId;
//       return store;
//     } else {
//       return new Store();
//     }
//   }

//   Store getStore(BuildContext context) {
//     /// get store for both Admin and staff roles
//     Store store =
//         Provider.of<CurrentUserProvider>(context, listen: false).isAdmin()
//             ? Provider.of<CurrentStoresProvider>(context, listen: false)
//                 .getSelectedStore
//             : Provider.of<CurrentUserProvider>(context, listen: false)
//                 .getloggedInUser
//                 .store;
//     return store;
//   }

//   int getStoreId(BuildContext context) {
//     /// get store id for both Admin and staff roles
//     int storeId =
//         Provider.of<CurrentUserProvider>(context, listen: false).isAdmin()
//             ? Provider.of<CurrentStoresProvider>(context, listen: false)
//                 .getSelectedStore
//                 .storeId
//             : Provider.of<CurrentUserProvider>(context, listen: false)
//                 .getloggedInUser
//                 .storeId;
//     return storeId;
//   }

//   // getStoreMenuId(BuildContext context) {
//   //   /// get store menu id for both Admin and staff roles
//   //   Store store = getStore(context);
//   //   // if (Provider.of<CurrentUserProvider>(context, listen: false).isAdmin()) {
//   //   //   if (storeMenuId != null) {
//   //   //     return storeMenuId;
//   //   //   } else {
//   //   //     // for admin, need to get store infor from api first
//   //   //     getSingleStoreById(context, store.storeId)
//   //   //         .then((value) => store = value);
//   //   //     storeMenuId = store.storeMenus.storeMenuId;
//   //   //   }
//   //   // } else {
//   //   //   return store.storeMenus.storeMenuId;
//   //   //   ;
//   //   // }
//   //   return store.storeMenus.storeMenuId;
//   // }
// }

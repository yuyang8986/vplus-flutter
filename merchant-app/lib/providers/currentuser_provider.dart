import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:vplus_merchant_app/models/apiUser.dart';
import 'package:vplus_merchant_app/models/organization.dart';
import 'package:vplus_merchant_app/models/store.dart';

class CurrentUserProvider with ChangeNotifier {
  Future<dynamic> checkExistingLoginFuture;
  ApiUser _loggedInUser;

  CurrentUserProvider() {
    checkExistingLoginFuture = checkExistingLogin();
  }

  ApiUser get getloggedInUser => _loggedInUser;

  setCurrentUser(ApiUser user) async {
    _loggedInUser = user;
    var hiveBox = await Hive.openBox('testBox');
    hiveBox.put("user", user.toJson());
    notifyListeners();
  }

  bool verifyRole(String roleName, ApiUser apiUser) {
    return apiUser.roleNames.contains(roleName);
  }

  bool isAdmin() {
    return _loggedInUser.roleNames.contains("OrganizationAdmin");
  }

  bool isSuperAdmin(){
    return _loggedInUser.roleNames.contains("SuperAdmin");
  }

  ApiUserRole getUserRole() {
    /// only check the first role of api users
    String currentUserRole = _loggedInUser.roleNames.first;
    switch (currentUserRole) {
      case "StoreKitchen":
        return ApiUserRole.StoreKitchen;
      case "OrganizationStaff":
        return ApiUserRole.OrganizationStaff;
      case "OrganizationAdmin":
        return ApiUserRole.OrganizationAdmin;
      case "SuperAdmin":
        return ApiUserRole.SuperAdmin;
      default:
        return ApiUserRole.OrganizationAdmin;
    }
  }

  Future<ApiUser> checkExistingLogin() async {
    try {
      var hiveBox = await Hive.openBox('testBox');
      var user = hiveBox.get('user');
      if (user != null) {
        _loggedInUser = new ApiUser();
        _loggedInUser.address = user['address'];
        _loggedInUser.name = user['name'];
        _loggedInUser.id = user['id'];
        _loggedInUser.mobile = user['mobile'];
        _loggedInUser.email = user['email'];
        _loggedInUser.token = user['token'];
        _loggedInUser.username = user['userName'];
        _loggedInUser.roleNames = user['roleNames'];
        _loggedInUser.organizationId = user['organizationId'];
        _loggedInUser.storeId = user['storeId'];
        _loggedInUser.isEmailVerified = user['isEmailVerified'];
        _loggedInUser.organization = user['organization'] == null
            ? null
            : Organization.fromJson(
                Map<String, dynamic>.from(user['organization']));
        _loggedInUser.store = user['store'] == null
            ? null
            : Store.fromJson(Map<String, dynamic>.from(user['store']));
        _loggedInUser.storeKitchenId = user['storeKitchenId'] ?? null;

        return _loggedInUser;
      }
      return null;
    } catch (e) {
      return Future.error(e);
    }
  }

  int get getCurrentUserStoreKitchenId => _loggedInUser.storeKitchenId;
}

import 'package:flutter/cupertino.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/models/userSavedAddress.dart';

class UserAddressProvider extends ChangeNotifier {
  int userId;
  List<UserSavedAddress> userSavedAddressList = [];

  Future<List<UserSavedAddress>> getUserAddressByUserId(
      BuildContext context, int userId) async {
    userSavedAddressList = [];
    var helper = Helper();
    var response = await helper.getData("api/users/addresses/$userId",
        context: context, hasAuth: true);
    if (response.isSuccess && response.data != null) {
      response.data.forEach((ow) {
        UserSavedAddress recvOS = UserSavedAddress.fromJson(ow);
        if (recvOS.isActive == true) {
          userSavedAddressList.add(recvOS);
        }
      });
      notifyListeners();
    } else {
      helper.showToastError('Unable to get your address, please try again');
    }
    return userSavedAddressList;
  }

  List<UserSavedAddress> get getUserSavedAddressList => userSavedAddressList;

  set setUserSavedAddressList(List<UserSavedAddress> newOrderList) =>
      userSavedAddressList = newOrderList;

  void deleteAddressFromUserSavedAddressList(UserSavedAddress address){
    userSavedAddressList.remove(address);
    notifyListeners();
  }
  Future <bool> deleteUserAddressByUserAddress
      (BuildContext context, UserSavedAddress address)async {
    var helper = Helper();
    var response = await helper.putData(
        "api/users/addresses/${address.userAddressId}/active?isActive=false",
        null,
        context: context,
        hasAuth: true);
    if(response.isSuccess){
      deleteAddressFromUserSavedAddressList(address);
      notifyListeners();
      return true;
    } else {
      helper.showToastError('Unable to delete your address, please try again');
      return false;
    }
  }

  void addAddressToUserSavedAddressList(UserSavedAddress os) {
    userSavedAddressList.add(os);
    notifyListeners();
  }
}

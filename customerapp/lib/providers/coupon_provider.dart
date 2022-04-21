import 'package:flutter/cupertino.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/models/coupon.dart';

class CouponProvider extends ChangeNotifier {
  Coupon coupon;
  bool isCouponAdded = false;

  Future<bool> getCouponInfoByCouponCode(BuildContext context,String couponCode) async {
    Helper hlp = Helper();
    isCouponAdded = false;
    var response = await hlp.getData("api/Campaign/coupons/info?code=$couponCode",
        context: context, hasAuth: true);
    if (response.isSuccess) {
      coupon = Coupon.fromJson(response.data);
      // update the placed order
      notifyListeners();
      isCouponAdded = true;
    }else{
      hlp.showToastError("Failed to get Coupon Info");
    }
    return response.isSuccess;
  }
  setIsCouponAdded(bool ifCouponAdded){
    isCouponAdded = ifCouponAdded;
  }
  Coupon get getCoupon => coupon;
  bool get getIfAdded => isCouponAdded;
}
class Coupon{
  String couponName;
  String couponDescription;
  String code;
  double percentOff;
  double amountOff;
  bool isActive;
  double minimumSpend;
  int maxRedemptionsAllowed;

  Coupon({
    this.couponName,
    this.couponDescription,
    this.code,
    this.percentOff,
    this.amountOff,
    this.isActive,
    this.minimumSpend,
    this.maxRedemptionsAllowed
  });

  Coupon.fromJson(Map<String, dynamic> json) {
    couponName = json['couponName'];
    couponDescription = json['couponDescription'];
    code = json['code'];
    percentOff = json['percentOff'];
    amountOff = json['amountOff'];
    isActive = json['isActive'];
    minimumSpend = json['minimumSpend'];
    maxRedemptionsAllowed = json['maxRedemptionsAllowed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['couponName'] = this.couponName;
    data['couponDescription'] = this.couponDescription;
    data['code'] = this.code;
    data['percentOff'] = this.percentOff;
    data['amountOff'] = this.amountOff;
    data['isActive'] = this.isActive;
    data['minimumSpend'] = this.minimumSpend;
    data['maxRedemptionsAllowed'] = this.maxRedemptionsAllowed;
    return data;
  }

}
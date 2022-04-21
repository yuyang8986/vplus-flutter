class UserPaymentMethod {
  String cardBrand;
  String cardNo;
  String expMonth;
  String expYear;

  UserPaymentMethod({this.cardBrand, this.cardNo, this.expMonth, this.expYear});

  UserPaymentMethod.fromJson(Map<String, dynamic> json) {
    cardBrand = json['cardBrand'];
    cardNo = json['cardNo'];
    expMonth = json['expMonth'];
    expYear = json['expYear'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cardBrand'] = this.cardBrand;
    data['cardNo'] = this.cardNo;
    data['expMonth'] = this.expMonth;
    data['expYear'] = this.expYear;
    return data;
  }
}

class UserSavedAddress{
  int userAddressId;
  String tag;
  String streetName;
  String streetNo;
  String unitNo;
  String contactName;
  String contactNo;
  String deliveryNote;
  String postCode;
  String city;
  String state;
  String country;
  bool isActive;
  int userId;
  String coordinate;

  UserSavedAddress(
      this.userAddressId,
      this.tag,
      this.streetName,
      this.streetNo,
      this.unitNo,
      this.contactName,
      this.contactNo,
      this.deliveryNote,
      this.postCode,
      this.city,
      this.state,
      this.country,
      this.isActive,
      this.userId,
      this.coordinate);
  UserSavedAddress.fromJson(Map<String, dynamic> json){
    userAddressId = json["userAddressId"];
    tag = json["tag"];
    streetName = json["streetName"];
    streetNo = json["streetNo"];
    unitNo = json["unitNo"];
    contactName = json["contactName"];
    contactNo = json["contactNo"];
    deliveryNote = json["deliveryNote"];
    postCode = json["postCode"];
    city = json["city"];
    state = json["state"];
    country = json["country"];
    isActive = json["isActive"];
    userId = json["userId"];
    coordinate = json["coordinate"];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["userAddressId"] = this.userAddressId;
    data["tag"] = this.tag;
    data["streetName"] = this.streetName;
    data["streetNo"] = this.streetNo;
    data["unitNo"] = this.unitNo;
    data["contactName"] = this.contactName;
    data["contactNo"] = this.contactNo;
    data["deliveryNote"] = this.deliveryNote;
    data["postCode"] = this.postCode;
    data["city"] = this.city;
    data["state"] = this.state;
    data["country"] = this.country;
    data["isActive"] = this.isActive;
    data["userId"] = this.userId;
    data["coordinate"] = this.coordinate;
    return data;
  }
  bool operator ==(o) => o is UserSavedAddress && o.userAddressId == userAddressId;
  int get hashCode => userAddressId.hashCode;
}
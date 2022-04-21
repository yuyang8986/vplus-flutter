class StoreKitchen {
  int storeKitchenId;
  String storeKitchenName;
  int storeId;

  StoreKitchen({
    this.storeKitchenId,
    this.storeKitchenName,
    this.storeId,
  });

  StoreKitchen.fromJson(Map<String, dynamic> json) {
    storeKitchenId = json['storeKitchenId'];
    storeKitchenName = json['storeKitchenName'];
    storeId = json['storeId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['storeKitchenId'] = this.storeKitchenId;
    data['storeKitchenName'] = this.storeKitchenName;
    data['storeId'] = this.storeId;
    return data;
  }
}
